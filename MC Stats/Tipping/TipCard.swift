import SwiftUI
import StoreKit

struct TipCard: View {
    @Environment(TipVM.self) private var vm
    
    private let product: Product
    
    init(_ product: Product) {
        self.product = product
    }
    
    var body: some View {
        Button {
            Task {
                await purchaseTip(product)
            }
        } label: {
            Text("Tip \(product.displayPrice)")
                .headline()
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding(.horizontal)
        .padding(.bottom, 3)
        .buttonStyle(.plain)
        .disabled(vm.isProcessing)
    }
    
    private func purchaseTip(_ product: Product) async {
#if !iMessage
#if os(macOS)
        let scene = NSApplication.shared.windows.first(where: { $0.isKeyWindow })
#else
        let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive })
#endif
        guard let scene else {
            vm.alertTitle = "Purchase Error"
            vm.alertMessage = "Could not find an active scene for the transaction"
            vm.showAlert = true
            return
        }
        
        vm.isProcessing = true
        
        defer {
            vm.isProcessing = false
        }
        
        do {
            if #available(macOS 15.2, *) {
                let result = try await product.purchase(confirmIn: scene, options: [])
                
                switch result {
                case .success(let verification):
                    switch verification {
                    case .verified(let transaction):
                        await handlePurchase(transaction)
                        
                    case .unverified(_, let error):
                        vm.alertTitle = "Purchase Error"
                        vm.alertMessage = "Transaction verification failed: \(error.localizedDescription)"
                        vm.showAlert = true
                    }
                    
                default:
                    break
                }
            } else {
                throw(SKError(.paymentNotAllowed))
            }
        } catch {
            vm.alertTitle = "Purchase Failed"
            vm.alertMessage = "There was an error processing your purchase: \(error.localizedDescription)"
            vm.showAlert = true
        }
#endif
    }
    
    // Handle successful purchase transaction
    private func handlePurchase(_ transaction: StoreKit.Transaction) async {
        // Process the purchase (e.g., thank the user, unlock features, etc)
        print("Purchase successful!")
        
        // Finish transaction
        await transaction.finish()
        
        vm.alertTitle = "Thank You"
        vm.alertMessage = "Thank you for supporting the development of MC Stats! Your contribution helps keep the app ad-free and open source for everyone!"
        vm.showAlert = true
    }
}

//#Preview {
//    TipCard()
//        .darkSchemePreferred()
//}
