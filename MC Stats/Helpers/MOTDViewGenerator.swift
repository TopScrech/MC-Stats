import SwiftUI
import MCStatsDataLayer

extension ServerStatus {
    public func generateMOTDView() -> Text {
        var combinedText = AttributedString()

        for section in description?.messageSections ?? [] {
            var text = AttributedString(section.text)
            var font = Font.minecraftFont

            if section.formatters.contains(.bold) {
                font = font.bold()
            }

            if section.formatters.contains(.italic) {
                font = font.italic()
            }

            text.font = font
            text.foregroundColor = section.color.isEmpty ? .white : Color(hex: section.color)

            if section.formatters.contains(.underline) {
                text.underlineStyle = .single
            }

            if section.formatters.contains(.strikethrough) {
                text.strikethroughStyle = .single
            }

            combinedText.append(text)
        }

        return Text(combinedText)
    }
}
