import ScrechKit
import SwiftData
import MCStatsDataLayer

@main
struct MCStatsApp: App {
    private let modelContainer = SwiftDataHelper.getModelContainter()

    var body: some Scene {
        WindowGroup {
            AppContainer()
        }
        .modelContainer(modelContainer)
        
#if os(macOS)
        Settings {
            NavigationStack {
                AppSettings()
            }
            .frame(width: 800, height: 600)
        }
        .modelContainer(modelContainer)
#endif
    }
}
