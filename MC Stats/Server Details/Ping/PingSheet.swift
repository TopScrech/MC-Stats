import ScrechKit

struct PingSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding private var data: [ServerPing]
    
    init(_ data: Binding<[ServerPing]>) {
        _data = data
    }
    
    @State private var selectedElement: ServerPing? = nil
    
    private var stats: PingStats {
        PingStats(data)
    }
    
    var body: some View {
        List {
            if data.isEmpty {
                ContentUnavailableView("No pings yet", systemImage: "chart.xyaxis.line")
            } else {
                Section {
                    PingStatsView(stats)
                    
                    PingGraphView(data, selectedElement: $selectedElement, average: stats.average)
                        .padding(.top)
                }
            }
        }
        .ornamentDismissButton()
        .toolbar {
#if os(macOS)
            ToolbarItemGroup {
                SFButton("xmark") {
                    dismiss()
                }
                
                Button("Clear") {
                    selectedElement = nil
                    data.removeAll()
                }
            }
#else
            ToolbarItem(placement: .topBarLeading) {
                SFButton("xmark") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Clear") {
                    selectedElement = nil
                    data.removeAll()
                }
            }
#endif
        }
#if os(macOS)
        .frame(minWidth: 600, minHeight: 500)
#endif
    }
}

#Preview {
    @Previewable @State var pings = (0..<20).map {
        ServerPing(Int.random(in: 10...100), date: Date().addingTimeInterval(Double($0)))
    }
    
    PingSheet($pings)
        .darkSchemePreferred()
}
