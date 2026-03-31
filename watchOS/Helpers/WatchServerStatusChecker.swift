import Foundation
import MCStatsDataLayer
import OSLog
import WatchConnectivity

private let logger = Logger()

@MainActor
final class WatchServerStatusChecker {
    var responseListener: ((UUID, ServerStatus) -> Void)?
    let connectivityProvider = ConnectivityProvider()
    var expectedResponseBatches: Set<ExpectedResultBatch> = Set()
    
    init() {
        self.connectivityProvider.responseListener = { response in
            // Recevied message from phone
            // Parse and remove from expected results, before passing on to listener
            guard let (serverID, status) = self.parseWatchResponse(response) else {
                return
            }
            
            logger.info("Received response from phone")
            
            for batch in self.expectedResponseBatches {
                batch.expectedResults.removeValue(forKey: serverID)
            }
            
            self.responseListener?(serverID, status)
        }
    }
    
    func checkServerAsync(_ server: SavedMinecraftServer) async -> ServerStatus {
        var didCallContinuation = false
        
        return await withCheckedContinuation { continuation in
            responseListener = {
                if !didCallContinuation {
                    didCallContinuation = true
                    continuation.resume(returning: $1)
                }
            }
            
            checkServers([server])
        }
    }
    
    func checkServers(_ servers: [SavedMinecraftServer]) {
        logger.info("Watch is going to ask for server status from phone")
        
        let serverBatch = servers.reduce(into: [UUID: SavedMinecraftServer]()) {
            $0[$1.id] = $1
        }
        
        let expectedBatch = ExpectedResultBatch(expectedResults: serverBatch)
        
        expectedResponseBatches.insert(expectedBatch)
        
        Task { @MainActor in
            do {
                var connectiveStateCounter = 0
                // first wait up to 1s for the phone to become available
                while (!WCSession.default.isReachable || WCSession.default.activationState != .activated) && connectiveStateCounter < 4 {
                    connectiveStateCounter += 1
                    try await Task.sleep(for: .milliseconds(250))
                }
                
                // only bother trying to connect via phone is it says it is reachable
                if WCSession.default.isReachable {
                    try checkServersViaPhone(servers)
                    // wait 8 seconds, and check if we need to backup for any of the pending servers
                    try await Task.sleep(for: .seconds(8))
                }
                
            } catch let error {
                logger.error("Failed to check servers via phone: \(error)")
            }
            
            // after timeout, anything left in the batch needs to be checked via the backup web API
            expectedBatch.expectedResults.forEach { id, server in
                // start new async task for each request to go in parrallel
                Task { @MainActor in
                    let status = await checkServerViaWeb(server)
                    self.responseListener?(id, status)
                }
            }
            
            expectedResponseBatches.remove(expectedBatch)
        }
    }
    
    private func parseWatchResponse(_ responseString: String) -> (UUID, ServerStatus)? {
        guard let jsonData = responseString.data(using: .utf8) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        
        do {
            let response = try decoder.decode(WatchResponseMessage.self, from: jsonData)
            return (response.id, response.status)
        } catch {
            logger.error("Error decoding: \(error)")
            return nil
        }
    }
    
    private func checkServersViaPhone(_ servers: [SavedMinecraftServer]) throws {
        let messageRequest = WatchRequestMessage()
        messageRequest.servers = servers
        
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(messageRequest)
        
        // Convert the JSON data to a string
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw ServerStatusCheckerError.StatusUnparsable
        }
        
        let payload = ["request": jsonString]
        
        logger.info("Sending request")
        try connectivityProvider.send(payload)
        
        logger.info("Try to send request")
    }
    
    // if we are calling third party do it individually so we can show the responses as they come in
    private func checkServerViaWeb(_ server: SavedMinecraftServer) async -> ServerStatus {
        do {
            logger.warning("Calling backup server")
            
            let serverType = server.serverType
            let serverURL = server.serverURL
            let serverPort = server.serverPort
            
            let res = try await WebServerStatusChecker.checkServer(
                serverType: serverType,
                serverURL: serverURL,
                serverPort: serverPort,
                config: nil
            )
            res.source = Source.ThirdParty
            
            logger.info("Got result from third party. Returning")
            
            return res
        } catch {
            // If not able to connect to the MC server directly, nor able to connect to the 3rd party server
            // We arent online at all most likely
            // Status is unknown (default value)
            logger.error("Error connecting to backup server, phone likely not connected: \(error)")
            return ServerStatus()
        }
    }
}
