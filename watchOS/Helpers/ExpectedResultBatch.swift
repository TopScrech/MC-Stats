import Foundation
import MCStatsDataLayer

final class ExpectedResultBatch: Hashable, @unchecked Sendable {
    let id = UUID()
    var expectedResults: [UUID: SavedMinecraftServer] = [:]
    
    init(expectedResults: [UUID: SavedMinecraftServer]) {
        self.expectedResults = expectedResults
    }
    
    static func == (lhs: ExpectedResultBatch, rhs: ExpectedResultBatch) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
