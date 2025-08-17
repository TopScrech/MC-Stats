import SwiftUI

final class ValueStore: ObservableObject {
    @AppStorage("appearance") var appearance: ColorTheme = .system
}
