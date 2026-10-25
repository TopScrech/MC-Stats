import SwiftUI

struct SiriGuide: View {
    private let phrases = [
        SiriPhrase("Check the status of my (Minecraft) server"),
        SiriPhrase("What's the status of my (Minecraft) server"),
        SiriPhrase("Check the status of [SERVER NAME]"),
        SiriPhrase("What's the status of [SERVER NAME]"),
        SiriPhrase("Check [SERVER NAME]'s status for me")
    ]
    
    var body: some View {
        Form {
            Section {
                ForEach(phrases) { phrase in
                    SiriGuidePhrase(phrase)
                }
            }
        }
        .navigationTitle("How to Use Siri")
    }
}
