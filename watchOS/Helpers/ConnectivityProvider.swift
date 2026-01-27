import OSLog
import WatchConnectivity

private let logger = Logger()

enum WatchConnectivityError: Error {
    case DeviceNotConnected, ResponseParseError
}

final class ConnectivityProvider: NSObject, WCSessionDelegate, @unchecked Sendable {
#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {}
#endif
    
    var responseListener: (([String: Any]) -> Void)?
    var connectionState: WCSessionActivationState = .inactive
    
    override init() {
        super.init()
        self.connect()
    }
    
    private func connect() {
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    // converted code to comminucate with iPhone as async/await
    // send a message to the phone. error throw if one is encountered
    func send(_ message: [String: Any]) throws {
        logger.info("Checking if phone is connected to watch")
        
        guard WCSession.default.isReachable else {
            // Phone not connected. throw error
            logger.warning("Phone is not connected")
            throw WatchConnectivityError.DeviceNotConnected
        }
        
        logger.info("Phone seems to be connected. Sending message to phone")
        
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            logger.error("Error trying to talk to phone: \(error)")
        }
    }
    
    // this should be where we recived the status from the iPhone after requesting it
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        responseListener?(message)
    }
    
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        logger.info("Watch session activationState: \(activationState.rawValue)")
        connectionState = activationState
    }
}
