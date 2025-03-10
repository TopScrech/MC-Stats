import SwiftUI

struct ConfigureWidgetView: View {
    @Environment(\.widgetFamily) private var widgetFamily
    
    private var scale: CGFloat {
        switch widgetFamily {
        case .systemMedium:
            1.25
            
        default:
            1
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label {
                Text("MC Stats")
                    .bold()
            } icon: {
                Image(.icon)
                    .resizable()
                    .frame(width: 32, height: 32)
                    .clipShape(.rect(cornerRadius: 8))
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text("1. **Long press** the widget")
                Text("2. Tap on **Edit Widget**")
                Text("3. **Choose your server** from the list")
            }
            .fontSize(10)
        }
        .padding()
        .scaleEffect(scale)
    }
}

#Preview {
    ConfigureWidgetView()
}
