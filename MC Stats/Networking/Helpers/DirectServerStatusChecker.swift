//
//  ServerStatusChecker.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 7/29/23.
//

import Foundation

class DirectServerStatusChecker {
    static func checkServer(serverUrl: String, serverPort: Int, serverType: ServerType) async throws -> ServerStatus {
        let statusChecker = ServerStatusCheckerFactory().getStatusChecker(serverUrl: serverUrl, serverPort: serverPort, serverType: serverType)
        let stringResult = try await statusChecker.checkServer()
        let result = try statusChecker.getParser().parseServerResponse(stringInput: stringResult)
        print("Successful connection and parsing. returning result.")
        return result
    }
}

//factory to dynamically handles creating the correct status checker for bedrock vs java
class ServerStatusCheckerFactory {
    func getStatusChecker(serverUrl: String, serverPort: Int, serverType: ServerType) -> ServerStatusCheckerProtocol {
        switch serverType {
        case .Java:
            JavaServerStatusChecker(serverAddress: serverUrl, port: serverPort)
        case .Bedrock:
            BedrockServerStatusChecker(serverAddress: serverUrl, port: serverPort)
        }
    }
}



