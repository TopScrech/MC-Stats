import AppIntents

// Converted for widget from previous intent
struct SelectServerIntent: AppIntent, WidgetConfigurationIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "ServerSelectIntent"
    
    static let title: LocalizedStringResource = "Server Select"
    static let description: IntentDescription = "Select which server to show"
    
    // Not for shortcuts
    static let isDiscoverable = false
    
    @Parameter(title: "Server")
    var Server: ServerIntentTypeAppEntity?
    
    @Parameter(title: "Theme")
    var Theme: ThemeIntentTypeAppEntity?
    
    @Parameter(title: "Show max player count", description: "Displays the max player count alongside the current number of players in the widgets", default: true)
    var showMaxPlayerCount: Bool
    
    static var parameterSummary: some ParameterSummary {
        Summary {
            \.$Server
            \.$Theme
            \.$showMaxPlayerCount
        }
    }
}
