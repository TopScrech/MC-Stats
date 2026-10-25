import Foundation
import OSLog

private let logger = Logger()

public class ServerStatusChecker {
    public static func checkServer(
        _ server: SavedMinecraftServer,
        config: ServerCheckerConfig? = nil
    ) async -> ServerStatus {
        let forceRefeshSrv = config?.forceSRVRefresh ?? false
        
        // first check if we need to refresh the srv
        if forceRefeshSrv {
            if let srvRecord = await SRVResolver.lookupMinecraftSRVRecord(server.serverURL),
               srvRecord.0 != server.srvServerURL || srvRecord.1 != server.srvServerPort {
                // got updated SRV info, updated it and try to connect
                server.srvServerURL = srvRecord.0
                server.srvServerPort = srvRecord.1
            }
        }
        
        logger.info("Starting server check for: \(server.serverURL)")
        
        // STEP 1 if we have SRV values, check that server
        // Only Java servers support SRV records
        if server.serverType == .Java && !server.srvServerURL.isEmpty && server.srvServerPort != 0 {
            do {
                logger.info("Checking server from cached SRV: \(server.srvServerURL)")
                
                let res = try await DirectServerStatusChecker.checkServer(
                    server,
                    config: config,
                    address: server.srvServerURL,
                    port: server.srvServerPort
                )
                res.source = .CachedSRV
                
                return res
            } catch {
                // something when horribly wrong
                // Move to next step
                logger.error("Error connecting to cached SRV: \(error)")
            }
        }
        
        // STEP 2 if the direct provided url is different that the SRV record, attempt to connect using that directly
        // ALSO THIS IS WHEN WE CONNECT TO BEDROCK SINCE THEY DONT HAVE SRV
        if server.serverType == .Bedrock || server.serverURL != server.srvServerURL || server.serverPort != server.srvServerPort {
            do {
                logger.info("Connecting to server directly, ignoring SRV")
                
                let res = try await DirectServerStatusChecker.checkServer(server, config: config)
                res.source = .Direct
                
                return res
            } catch {
                // something when horribly wrong. Move to next step
                logger.error("Error connecting to manual server and port: \(error)")
            }
        }
        
        // STEP 3 first check if we already tried ot refresh the SRV based on previous forcing
        // if not, and we still could not connect, refresh the SRV if its a java server, maybe there is an update
        // if we recevied updated values from previous SRV, attempt ot connect using that
        if !forceRefeshSrv && server.serverType == .Java {
            if let srvRecord = await SRVResolver.lookupMinecraftSRVRecord(server.serverURL),
               (srvRecord.0 != server.srvServerURL || srvRecord.1 != server.srvServerPort) {
                // got updated SRV info, updated it and try to connect
                
                server.srvServerURL = srvRecord.0
                server.srvServerPort = srvRecord.1
                
                // we need to save it in swift data here
                logger.info("Found new SRV record from DNS, checking server at: \(server.srvServerURL)")
                
                do {
                    let res = try await DirectServerStatusChecker.checkServer(
                        server,
                        config: config,
                        address: server.srvServerURL,
                        port: server.srvServerPort
                    )
                    res.source = .UpdatedSRV
                    
                    return res
                } catch {
                    // something when horribly wrong
                    // Move to next step
                    logger.error("Error connecting to new SRV: \(error)")
                }
            }
        }
        
        // STEP 4 if all else fails, ask 3rd party web server for info
        // if we hear back from the 3rd party server, and they also say the server is offline, we can agree its offline
        do {
            logger.warning("Calling backup server")
            
            let res = try await WebServerStatusChecker.checkServer(
                serverType: server.serverType,
                serverURL: server.serverURL,
                serverPort: server.serverPort,
                config: config
            )
            res.source = .ThirdParty
            
            logger.info("Got result from third party, returning")
            
            return res
        } catch {
            // if we arent able to connect to the minecraft server directly, nor are we able to connect to the 3rd party server
            // we arent online at all most likely. status is unknown (default value)
            logger.error("Error connecting to backup server, phone likely not connected: \(error)")
            
            return ServerStatus()
        }
    }
}

public struct ServerCheckerConfig {
    public var sortUsers = false
    public var forceSRVRefresh = false
    
    public init(sortUsers: Bool = false, forceSRVRefresh: Bool = false) {
        self.forceSRVRefresh = forceSRVRefresh
        self.sortUsers = sortUsers
    }
}
