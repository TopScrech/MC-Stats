import SwiftUI
import MCStatsDataLayer

struct SettingsView: View {
    private let reloadServers: () -> Void
    
    init(reloadServers: @escaping () -> Void = {}) {
        self.reloadServers = reloadServers
    }
    
    @State private var sheetAdd = false
    
    @State private var newServer = SavedMinecraftServer.initialize(
        id: UUID(),
        serverType: .Java,
        name: "",
        serverURL: "",
        serverPort: 0,
        srvServerURL: "",
        srvServerPort: 0,
        serverIcon: "",
        displayOrder: 0
    )
    
    var body: some View {
        List {
            Button("Add Server", systemImage: "plus") {
                sheetAdd = true
            }
            
            DebugSettings {
                reloadServers()
            }
        }
        .sheet($sheetAdd) {
            EditServerView($newServer) {
                reloadServers()
            }
        }
    }
}

#Preview {
    SettingsView()
        .darkSchemePreferred()
}
