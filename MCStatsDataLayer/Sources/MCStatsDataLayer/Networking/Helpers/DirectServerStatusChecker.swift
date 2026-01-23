import Foundation

public class DirectServerStatusChecker {
    public static func checkServer(_ server: SavedMinecraftServer, config: ServerCheckerConfig?) async throws -> ServerStatus {
        let statusChecker = ServerStatusCheckerFactory().getStatusChecker(server)
        
        let stringResult = try await statusChecker.checkServer()
        
        print(stringResult)
        
        let result = try statusChecker.getParser().parseServerResponse(
            stringInput: stringResult,
            config: config
        )
        
        print("Successful connection and parsing, returning result")
        
        return result
    }
}

// Factory to dynamically handles creating the correct status checker for bedrock vs java
public class ServerStatusCheckerFactory {
    public func getStatusChecker(_ server: SavedMinecraftServer) -> ServerStatusCheckerProtocol {
        switch server.serverType {
        case .Java:
            JavaServerStatusChecker(address: server.serverURL, port: server.serverPort)
            
        case .Bedrock:
            BedrockServerStatusChecker(address: server.serverURL, port: server.serverPort)
        }
    }
}
