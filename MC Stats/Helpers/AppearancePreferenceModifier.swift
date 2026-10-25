import SwiftUI
#if canImport(Appearance)
import Appearance

struct AppearancePreferenceModifier: ViewModifier {
    @Environment(\.colorScheme) private var inheritedColorScheme
    @AppStorage("appearance") private var appearance: Appearance = .system

    var presentingColorScheme: ColorScheme?

    func body(content: Content) -> some View {
        content
            .environment(\.colorScheme, appearance.scheme ?? presentingColorScheme ?? inheritedColorScheme)
            .preferredColorScheme(appearance.scheme ?? presentingColorScheme)
    }
}
#endif
