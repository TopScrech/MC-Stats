import Foundation
import OSLog
import SwiftData

private let logger = Logger()

public class SwiftDataHelper {
    public static func getModelContainter() -> ModelContainer {
        if UserDefaultsHelper.shared.get(for: .iCloudEnabled, defaultValue: true) {
            do {
                let config = ModelConfiguration(
                    nil,
                    schema: Schema ([SavedMinecraftServer.self]),
                    isStoredInMemoryOnly: false,
                    allowsSave: true,
                    groupContainer: ModelConfiguration.GroupContainer.automatic,
                    cloudKitDatabase: ModelConfiguration.CloudKitDatabase.automatic
                )
                
                return try ModelContainer(for: SavedMinecraftServer.self, configurations: config)
            } catch {
                // something broken with icloud? continue with local container without config
                logger.error("Error loading iCloud model container: \(error)")
            }
        }
        
        // if this is broken then something is f'ed up. just crash
        return try! ModelContainer(for: SavedMinecraftServer.self)
    }
    
    public static func getSavedServersBg(_ container: ModelContainer) -> [SavedMinecraftServer] {
        let modelContext = ModelContext(container)
        
        let fetch = FetchDescriptor<SavedMinecraftServer>(
            predicate: nil,
            sortBy: [.init(\.displayOrder)]
        )
        
        guard let results = try? modelContext.fetch(fetch) else {
            return []
        }
        
        return results
    }
    
    public static func getSavedServers(_ container: ModelContainer) -> [SavedMinecraftServer] {
        let modelContext = ModelContext(container)
        
        let fetch = FetchDescriptor<SavedMinecraftServer>(
            predicate: nil,
            sortBy: [.init(\.displayOrder)]
        )
        
        guard let results = try? modelContext.fetch(fetch) else {
            return []
        }
        
        return results
    }
    
    public static func getSavedServerById(_ id: UUID, from container: ModelContainer) -> SavedMinecraftServer? {
        let modelContext = ModelContext(container)
        
        let serverPredicate = #Predicate<SavedMinecraftServer> {
            $0.id == id
        }
        
        var fetch = FetchDescriptor<SavedMinecraftServer>(
            predicate: serverPredicate,
            sortBy: [.init(\.displayOrder)]
        )
        
        fetch.fetchLimit = 1
        
        guard
            let results = try? modelContext.fetch(fetch),
            results.count > 0
        else {
            return nil
        }
        
        return results.first
    }
}
