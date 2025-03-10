import SwiftUI

struct FAQ: Identifiable {
    let id = UUID()
    let question: LocalizedStringKey
    let answer: LocalizedStringKey
    
    init(_ question: LocalizedStringKey, answer: LocalizedStringKey) {
        self.question = question
        self.answer = answer
    }
}
