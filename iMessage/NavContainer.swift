import SwiftUI
import SwiftData
import MCStatsDataLayer

struct NavContainer: View {
    @State private var fullScreen = false
    
    var body: some View {
        VStack {
            Text("Full-screen only")
            
            Button("Open in full screen") {
                fullScreen = true
            }
        }
        .fullScreenCover($fullScreen) {
            ServerList()
                .modelContainer(SwiftDataHelper.getModelContainter())
        }
    }
}
