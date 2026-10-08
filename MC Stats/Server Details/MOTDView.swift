import SwiftUI
import MCStatsDataLayer

struct MOTDView: View {
    private let status: ServerStatus?
    
    init(_ status: ServerStatus?) {
        self.status = status
    }
    
    var body: some View {
        if let status, status.description != nil {
            status.generateMOTDView()
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .shadow(radius: 5)
                .padding(10)
                .frame(maxWidth: .infinity)
                .clipShape(.rect(cornerRadius: 15))
        }
    }
}

//#Preview {
//    MOTDView()
//    .darkSchemePreferred()
//}
