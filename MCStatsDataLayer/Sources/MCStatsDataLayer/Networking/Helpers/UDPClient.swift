import Foundation
import Network
import OSLog

public enum UDPResponseType {
    case SUCCESS, ERROR
}

public class UDPClient {
    var connection: NWConnection
    var address: NWEndpoint.Host
    var port: NWEndpoint.Port
    var listener: (_ responseType: UDPResponseType, _ client: UDPClient?, _ data: Data?) -> Void
    var didRecieveData = false
    
    var resultHandler = NWConnection.SendCompletion.contentProcessed { NWError in
        guard NWError == nil else {
            if let error = NWError {
                Logger().error("Error sending data: \(error)")
            } else {
                Logger().error("Error sending data: unknown")
            }
            return
        }
        
        Logger().info("Data sent successfully")
    }
    
    public init?(address newAddress: String, port newPort: Int32, listener: @escaping (_ responseType: UDPResponseType, _ client: UDPClient?, _ data: Data?) -> Void) {
        self.listener = listener
        
        guard
            let codedPort = NWEndpoint.Port(rawValue: NWEndpoint.Port.RawValue(newPort))
        else {
            Logger().error("Failed to create connection address")
            self.listener(.ERROR, nil, nil)
            
            return nil
        }
        
        address = NWEndpoint.Host(newAddress)
        port = codedPort
        
        connection = NWConnection(
            host: address,
            port: port,
            using: .udp
        )
        
        connection.stateUpdateHandler = { newState in
            switch (newState) {
            case .ready:
                Logger().info("State: Ready")
                return
                
            case .setup:
                Logger().info("State: Setup")
                
            case .cancelled:
                Logger().info("State: Cancelled")
                
            case .preparing:
                Logger().info("State: Preparing")
                
            default:
                Logger().error("State not defined")
                self.listener(.ERROR, nil, nil)
                
            }
        }
        
        connection.start(queue: .global())
    }
    
    deinit {
        if connection.state != .cancelled {
            connection.cancel()
        }
    }
    
    // SETUP WITH A 3 SECOND TIMEOUT
    func send(_ data: Data) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if !self.didRecieveData {
                self.listener(.ERROR, self, nil)
            }
        }
        
        Logger().info("Sending data")
        self.connection.send(content: data, completion: self.resultHandler)
        
        self.connection.receiveMessage { data, context, isComplete, error in
            self.didRecieveData = true
            
            guard let data else {
                Logger().error("Received nil data")
                
                self.listener(.ERROR, self, nil)
                return
            }
            
            Logger().info("Received valid data")
            self.listener(.SUCCESS, self, data)
        }
    }
}
