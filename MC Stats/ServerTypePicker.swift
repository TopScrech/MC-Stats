import SwiftUI
import MCStatsDataLayer

struct ServerTypePicker: View {
    @Binding var tempServerType: ServerType
    @Binding var portLabelPromptText: String
    
    private let title: LocalizedStringKey
    
    init(
        _ tempServerType: Binding<ServerType>,
        portLabelPromptText: Binding<String>,
        title: LocalizedStringKey = "Server Type"
    ) {
        _tempServerType = tempServerType
        _portLabelPromptText = portLabelPromptText
        self.title = title
    }
    
    var body: some View {
        Picker(title, selection: $tempServerType) {
            Text("Java Edition")
                .tag(ServerType.Java)
            
            Text("Bedrock/MCPE")
                .tag(ServerType.Bedrock)
        }
        .onChange(of: tempServerType) { _, newValue in
            portLabelPromptText = defaultPortPrompt(for: newValue)
        }
    }
    
    private func defaultPortPrompt(for serverType: ServerType) -> String {
        switch serverType {
        case .Java: "Port (Optional - Default 25565)"
        case .Bedrock: "Port (Optional - Default 19132)"
        }
    }
}
