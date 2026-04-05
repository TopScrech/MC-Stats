import ScrechKit

struct PingSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding private var data: [ServerPing]
    
    init(_ data: Binding<[ServerPing]>) {
        _data = data
    }
    
    @State private var selectedElement: ServerPing? = nil
    
    var average: Int {
        guard !data.isEmpty else {
            return 0
        }
        
        let avg = data.map {
            Double($0.ping)
        }.reduce(0, +) / Double(data.count)
        
        return Int(avg)
    }
    
    var body: some View {
        List {
            Section("Average: \(average) ms") {
                PingChart($data, selectedElement: $selectedElement, average: average)
            }
        }
        .ornamentDismissButton()
        .toolbar {
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
