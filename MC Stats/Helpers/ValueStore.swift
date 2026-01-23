import SwiftUI
import Appearance

final class ValueStore: ObservableObject {
    @AppStorage("appearance") var appearance: Appearance = .system
}
