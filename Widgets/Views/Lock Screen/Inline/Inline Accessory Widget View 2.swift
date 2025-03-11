import SwiftUI
import Intents
import WidgetKit

struct InlineAccessoryWidgetView2: View {
    private var entry: LockscreenProvider.Entry
    
    init(_ entry: LockscreenProvider.Entry) {
        self.entry = entry
    }
    
    var body: some View {
#if !os(macOS)
        HStack(spacing: 3) {
            Button(intent: RefreshWidgetIntent()) {
                if entry.vm.viewType == .Unconfigured {
#if os(watchOS)
                    Text("...")
#else
                    Text("Edit Widget")
#endif
                } else {
                    if entry.configuration.showMaxPlayerCount {
                        Text(entry.vm.progressString)
                    } else {
                        Text(entry.vm.playersOnline)
                    }
                }
            }
            .buttonStyle(.plain)
            
            if let statusIcon = entry.vm.statusIcon {
                Image(systemName: statusIcon)
                    .fontSize(18)
                    .widgetAccentable()
                
            } else if entry.vm.viewType != .Unconfigured {
                // Due to the incompatibility of Gauge, ProgressView, and Shapes in inline widgets,
                // we must rely on 101 assets, each representing a specific progress percentage
                
                let imageNumber = min(100, max(0, Int((entry.vm.progressValue * 100).rounded(.towardZero))))
                let imageName = "ProgressBar\(imageNumber)"
                
                if let uiImage = UIImage(named: imageName) {
                    Image(uiImage: uiImage)
                        .padding()
                        .widgetAccentable()
                }
            }
        }
#endif
    }
}
