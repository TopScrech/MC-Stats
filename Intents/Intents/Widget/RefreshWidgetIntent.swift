import AppIntents

struct RefreshWidgetIntent: AppIntent {
    static let title: LocalizedStringResource = "Refresh Widget"
    static let isDiscoverable = false
    
    func perform() async throws -> some IntentResult {
        // try await Task.sleep(nanoseconds: UInt64(10) * NSEC_PER_SEC)
        .result()
    }
}
