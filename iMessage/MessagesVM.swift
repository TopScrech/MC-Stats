import OSLog
import SwiftUI
import Messages

@Observable
final class MessagesVM {
    private let logger = Logger()
    private var vc: MessagesViewController?
    
    init(_ vc: MessagesViewController?) {
        self.vc = vc
    }
    
    var message = "Hello from ViewModel!"
    
    func updateMessage(newMessage: String) {
        message = newMessage
    }
    
    func sendMessage(_ text: String) {
        guard let conversation = vc?.conversation else {
            logger.warning("No active conversation")
            return
        }
        
        let message = MSMessage()
        let layout = MSMessageTemplateLayout()
        layout.caption = "text"
        layout.subcaption = "text"
        layout.image = UIImage(named: "artwork")
        layout.imageTitle = "Luza"
        layout.imageSubtitle = "Flufa"
        layout.trailingCaption = "11"
        layout.trailingSubcaption = "22"
        message.layout = layout
        
        conversation.insert(message) { error in
            if let error {
                self.logger.error("Error sending message: \(error)")
            }
        }
    }
}
