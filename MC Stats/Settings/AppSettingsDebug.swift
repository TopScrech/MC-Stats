import MCStatsDataLayer
import OSLog
import SwiftData
import SwiftUI

struct AppSettingsDebug: View {
    @Query private var servers: [SavedMinecraftServer]
    @Environment(\.modelContext) private var modelContext
    
    private let logger = Logger()
    
    let reloadServers: () -> Void
    
    @State private var confirmDeleteAll = false
    
    var body: some View {
        Section {
            Button("Add test servers", systemImage: "plus") {
                addTestServers()
            }
            
            Button("Delete all servers", systemImage: "trash", role: .destructive) {
                confirmDeleteAll = true
            }
            .foregroundStyle(.red)
            .confirmationDialog("Are you sure?", isPresented: $confirmDeleteAll) {
                Button("Delete all servers", role: .destructive) {
                    deleteAllServers()
                }
            }
        } header: {
            Text("Debug")
        } footer: {
#if os(macOS)
            Text("Might require a restart")
#endif
        }
    }
    
    private func deleteAllServers() {
        servers.forEach {
            modelContext.delete($0)
        }
        
        do {
            try modelContext.save()
        } catch {
            logger.error("Error deleting all servers: \(error)")
        }
        
        reloadServers()
    }
    
    private func addTestServers() {
        modelContext.insert(SavedMinecraftServer.initialize(id: UUID(), serverType: .Java, name: "Insanity Craft", serverURL: "join.insanitycraft.net", serverPort: 25565))
        modelContext.insert(SavedMinecraftServer.initialize(id: UUID(), serverType: .Java, name: "OpBlocks", serverURL: "hub.opblocks.com", serverPort: 25565))
        modelContext.insert(SavedMinecraftServer.initialize(id: UUID(), serverType: .Java, name: "Ace MC", serverURL: "mc.acemc.co", serverPort: 25565))
        modelContext.insert(SavedMinecraftServer.initialize(id: UUID(), serverType: .Java, name: "Vanilla Realms", serverURL: "mcs.vanillarealms.com", serverPort: 25565))
        modelContext.insert(SavedMinecraftServer.initialize(id: UUID(), serverType: .Java, name: "Earth MC", serverURL: "org.earthmc.net", serverPort: 25565))
        modelContext.insert(SavedMinecraftServer.initialize(id: UUID(), serverType: .Java, name: "Zero's Server", serverURL: "zero.minr.org", serverPort: 25565))
        modelContext.insert(SavedMinecraftServer.initialize(id: UUID(), serverType: .Java, name: "Rainy Day", serverURL: "rainyday.gg", serverPort: 25565))
        modelContext.insert(SavedMinecraftServer.initialize(id: UUID(), serverType: .Java, name: "Harmony Server", serverURL: "join.harmonyfallssmp.world", serverPort: 25565))
        modelContext.insert(SavedMinecraftServer.initialize(id: UUID(), serverType: .Bedrock, name: "Fade Cloud", serverURL: "mp.fadecloud.com", serverPort: 19132))
        modelContext.insert(SavedMinecraftServer.initialize(id: UUID(), serverType: .Bedrock, name: "MC Hub", serverURL: "mps.mchub.com", serverPort: 19132))
        
        reloadServers()
    }
}

#Preview {
    AppSettingsDebug {}
        .darkSchemePreferred()
}
