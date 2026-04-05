import SwiftUI

struct PingSheet: View {
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
            Section {
                PingChart($data, selectedElement: $selectedElement, average: average)
            } footer: {
                Text("**Hold and drag** over the chart to view and move the lollipop")
            }
            
            Section {
                Text("Average: \(average) ms")
                
                Button("Clear") {
                    selectedElement = nil
                    data.removeAll()
                }
            }
        }
        .ornamentDismissButton()
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
