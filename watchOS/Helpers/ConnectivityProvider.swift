import OSLog
import WatchConnectivity

enum WatchConnectivityError: Error {
    case DeviceNotConnected, ResponseParseError
}

final class ConnectivityProvider: NSObject, WCSessionDelegate, @unchecked Sendable {
#if os(iOS)
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}
    
    nonisolated func sessionDidDeactivate(_ session: WCSession) {}
#endif
    
    var responseListener: (@MainActor @Sendable (String) -> Void)?
    
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
        let logger = Logger()
        
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
    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        let logger = Logger()
        
        guard let response = message["response"] as? String else {
            logger.error("Watch response payload missing response string")
            return
        }
        
        Task { @MainActor [weak self, response] in
            self?.responseListener?(response)
        }
    }
    
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        let logger = Logger()
        
        logger.info("Watch session activationState: \(activationState.rawValue)")
        
        if let error {
            logger.error("Watch session activation failed: \(error)")
        }
    }
}
