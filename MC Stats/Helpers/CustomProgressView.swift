import SwiftUI

struct CustomProgressView: View {
    var progress: CGFloat
    var bgColor = Color.gray
    var bgOpacity = 1.0
    var filledColor = Color.green
    
    var body: some View {
        GeometryReader {
            let height = $0.size.height
            let width = $0.size.width
            let percentage = progress > 1 ? 1 : progress
            
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(bgColor)
                    .frame(width: width, height: height)
                    .cornerRadius(height / 2)
                    .opacity(bgOpacity)
                
                Rectangle()
                    .foregroundColor(filledColor)
                    .frame(width: width * percentage, height: height)
                    .cornerRadius(height / 2)
                    .animation(.easeInOut(duration: 0.5), value: progress)
#if canImport(WidgetKit)
                    .widgetAccentable()
#endif
            }
        }
    }
}
