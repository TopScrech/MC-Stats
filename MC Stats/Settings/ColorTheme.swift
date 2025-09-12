import SwiftUI

enum ColorTheme: String, Identifiable, CaseIterable {
    case system, dark, light
    
    var id: String {
        self.rawValue
    }
    
    var scheme: ColorScheme? {
        switch self {
        case .system: .none
        case .dark:   .dark
        case .light:  .light
        }
    }
    
    var loc: LocalizedStringKey {
        switch self {
        case .system: "System"
        case .dark: "Dark"
        case .light: "Light"
        }
    }
}
