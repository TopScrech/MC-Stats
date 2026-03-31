import MCStatsDataLayer
import SwiftData
import WatchConnectivity
import OSLog

final class WatchHelper: NSObject, WCSessionDelegate {
    override init() {
        super.init()
#warning("WatchHelper disabled")
        //        connect()
    }
    
    func connect() {
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        let logger = Logger(subsystem: "dev.topscrech.MC-Stats", category: "WatchHelper")
        
        logger.info("Watch session changed state: \(activationState.rawValue)")
        
        if let error {
            logger.error("Watch session activation failed: \(error)")
        }
    }
    
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {
        let logger = Logger(subsystem: "dev.topscrech.MC-Stats", category: "WatchHelper")
        
        logger.info("Watch session became inactive")
    }
    
    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        let logger = Logger(subsystem: "dev.topscrech.MC-Stats", category: "WatchHelper")
        
        logger.info("Watch session deactivated")
    }
    
    nonisolated func handleWatchMessage(message: [String: Any], session: WCSession) {
        let logger = Logger(subsystem: "dev.topscrech.MC-Stats", category: "WatchHelper")
        let decoder = JSONDecoder()
        
        // I've done the lazy thing and hard coded the logic directly in here
        // Should be moved to a helper func at some point
        guard
            let requestString = message["request"] as? String,
            let jsonData = requestString.data(using: .utf8),
            let request = try? decoder.decode(WatchRequestMessage.self, from: jsonData)
        else {
            // unknown input? return nothing
            logger.error("Error parsing watch request")
            return
        }
        
        // for each server, get response, and send responses back as we receive them to the watch
        // we start a new task for each server to let them run in parrallel
        for server in request.servers {
            let serverID = server.id
            let serverType = server.serverType
            let name = server.name
            let serverURL = server.serverURL
            let serverPort = server.serverPort
            let srvServerURL = server.srvServerURL
            let srvServerPort = server.srvServerPort
            let serverIcon = server.serverIcon
            let displayOrder = server.displayOrder
            
            Task {
                let logger = Logger(subsystem: "dev.topscrech.MC-Stats", category: "WatchHelper")
                
                let server = SavedMinecraftServer.initialize(
                    id: serverID,
                    serverType: serverType,
                    name: name,
                    serverURL: serverURL,
                    serverPort: serverPort,
                    srvServerURL: srvServerURL,
                    srvServerPort: srvServerPort,
                    serverIcon: serverIcon,
                    displayOrder: displayOrder
                )
                
                let result = await ServerStatusChecker.checkServer(server)
                let messageResponse = WatchResponseMessage(id: serverID, status: result)
                
                let encoder = JSONEncoder()
                let jsonData = try encoder.encode(messageResponse)
                
                // Convert the JSON data to a string
                guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                    throw ServerStatusCheckerError.StatusUnparsable
                }
                
                let payload = ["response": jsonString]
                
                logger.info("Sending status response to watch")
                
                WCSession.default.sendMessage(payload, replyHandler: nil) { error in
                    logger.error("Error sending status response to watch: \(error)")
                }
            }
        }
    }
    
    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        let logger = Logger(subsystem: "dev.topscrech.MC-Stats", category: "WatchHelper")
        
        logger.info("Received watch background request for data")
        
        // initilize model container since sometimes it's not ready yet??
        // https://developer.apple.com/forums/thread/734212
        let container = SwiftDataHelper.getModelContainter()
        
        handleWatchMessage(message: message, session: session)
        
        logger.info("Container: \(container.schema.debugDescription)")
    }
}
