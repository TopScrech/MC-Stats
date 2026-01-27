import Foundation
import OSLog

private let logger = Logger()

public class DirectServerStatusChecker {
    public static func checkServer(
        _ server: SavedMinecraftServer,
        config: ServerCheckerConfig?,
        address: String? = nil,
        port: Int? = nil
    ) async throws -> ServerStatus {
        let resolvedAddress = address ?? server.serverURL
        let resolvedPort = port ?? server.serverPort
        
        let statusChecker = ServerStatusCheckerFactory().getStatusChecker(
            serverType: server.serverType,
            address: resolvedAddress,
            port: resolvedPort
        )
        
        let stringResult = try await statusChecker.checkServer()
        
        logger.info("Raw status response: \(stringResult)")
        
        let result = try statusChecker.getParser().parseServerResponse(
            stringInput: stringResult,
            config: config
        )
        
        logger.info("Successful connection and parsing, returning result")
        
        return result
    }
}

// Factory to dynamically handles creating the correct status checker for bedrock vs java
public class ServerStatusCheckerFactory {
    public func getStatusChecker(
        serverType: ServerType,
        address: String,
        port: Int
    ) -> ServerStatusCheckerProtocol {
        switch serverType {
        case .Java:
            JavaServerStatusChecker(address: address, port: port)
            
        case .Bedrock:
            BedrockServerStatusChecker(address: address, port: port)
        }
    }
}
