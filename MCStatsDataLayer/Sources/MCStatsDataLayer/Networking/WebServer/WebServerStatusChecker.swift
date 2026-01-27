import Foundation

// Class for calling MCStatus API when direct connection fails
public class WebServerStatusChecker {
    static let API_URL = "https://api.mcstatus.io/v2/status/"
    static let timeout = 4
    
    public static func checkServer(
        serverType: ServerType,
        serverURL: String,
        serverPort: Int,
        config: ServerCheckerConfig?
    ) async throws -> ServerStatus {
        var urlString = WebServerStatusChecker.API_URL
        
        if serverType == .Java {
            urlString += "java/"
        } else {
            urlString += "bedrock/"
        }
        
        urlString += serverURL + ":" + String(serverPort) + "?timeout=" + String(timeout)
        
        let url = URL(string: urlString)!
        let urlSession = URLSession.shared
        
        let (data, response) = try await urlSession.data(from: url)
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        
        guard statusCode == 200 else {
            if statusCode == 400 {
                // if the backup server returns a 400, then we address we supplied is invalid, so the server is offline
                let status = ServerStatus()
                status.status = .offline
                
                return status
            } else {
                throw ServerStatusCheckerError.DeviceNotConnected
            }
        }
        
        if serverType == .Java {
            let decodedObj = try JSONDecoder().decode(WebJavaServerStatusResponse.self, from: data)
            
            return try WebServerStatusParser.parseServerResponse(input: decodedObj, config: config)
        } else {
            let decodedObj = try JSONDecoder().decode(WebBedrockServerStatusResponse.self, from: data)
            
            return try WebServerStatusParser.parseServerResponse(input: decodedObj, config: config)
        }
    }
}
