import ScrechKit
import MCStatsDataLayer

@main
struct MCStatsApp: App {
#if os(iOS)
    @StateObject private var store = ValueStore()
#endif
    
    var body: some Scene {
        WindowGroup {
            AppContainer()
#if os(iOS)
                .environmentObject(store)
#endif
        }
        .modelContainer(SwiftDataHelper.getModelContainter())
        
#if os(macOS)
        Settings {
            NavigationStack {
                SettingsView()
            }
            .frame(width: 800, height: 600)
        }
        .modelContainer(SwiftDataHelper.getModelContainter())
#endif
    }
}
