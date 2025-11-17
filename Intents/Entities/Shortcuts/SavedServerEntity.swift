import SwiftUI
import AppIntents
import MCStatsDataLayer

struct SavedServerEntity: AppEntity {
    var id: UUID
    var serverName: String
    var icon: String
    var type: String
    
    init(_ server: SavedMinecraftServer) {
        self.id = server.id
        self.serverName = server.name
        self.icon = server.serverIcon
        self.type = server.serverType.rawValue
    }
    
    static let defaultQuery = SavedServerQuery()
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Server"
    
    var displayRepresentation: DisplayRepresentation {
#if os(macOS)
        let image = ImageHelper.favIconString(icon) ?? NSImage(named: "DefaultIcon") ?? NSImage()
        let imageData = image.tiffRepresentation ?? Data()
#else
        let image = ImageHelper.favIconString(icon) ?? UIImage(named: "DefaultIcon") ?? UIImage()
        let imageData = image.pngData() ?? Data()
#endif
        return DisplayRepresentation(
            title: "\(serverName)",
            subtitle: "\(type)",
            image: .init(data: imageData)
        )
    }
}

struct SavedServerQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [SavedServerEntity] {
        let container = SwiftDataHelper.getModelContainter()
        var result: [SavedServerEntity] = []
        
        for id in identifiers {
            guard let server = await SwiftDataHelper.getSavedServerById(id, from: container) else {
                continue
            }
            
            result.append(SavedServerEntity(server))
        }
        
        return result
    }
    
    func suggestedEntities() async throws -> [SavedServerEntity] {
        let container = SwiftDataHelper.getModelContainter()
        let servers = await SwiftDataHelper.getSavedServers(container)
        
        return servers.compactMap(SavedServerEntity.init)
    }
}
