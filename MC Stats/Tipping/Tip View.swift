import SwiftUI
import StoreKit

struct TipView: View {
    @State private var vm = TipVM()
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var tipProducts: [Product]?
    
    var body: some View {
        @Bindable var vm = vm
        
        ScrollView {
            VStack(spacing: 15) {
                Text("Support the app!")
                    .largeTitle(.bold)
                    .padding(.top)
                
                Image(systemName: "party.popper.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding()
                
                Text("This app is free and open-source. If you find it useful, consider tipping to help keep it going!")
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .padding()
                
                if let products = tipProducts {
                    ForEach(products) { product in
                        TipCard(product)
                            .environment(vm)
                    }
                } else {
                    ProgressView()
                }
                
                Button {
                    Task {
                        await restorePurchases()
                    }
                } label: {
                    if vm.isRestoring {
                        ProgressView()
                    } else {
                        Text("Restore Purchases")
                            .footnote()
                            .secondary()
                    }
                }
                .foregroundStyle(.foreground)
                .buttonStyle(.plain)
                .disabled(vm.isRestoring)
#if os(macOS)
                Button("Dismiss") {
                    dismiss()
                }
                .padding(.bottom)
#endif
            }
            .padding(.horizontal)
        }
        .task {
            await loadTipProducts()
        }
        .alert(vm.alertTitle, isPresented: $vm.showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(vm.alertMessage)
        }
#if !os(macOS)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
#endif
    }
    
    private func restorePurchases() async {
        vm.isRestoring = true
        
        for await result in Transaction.updates {
            _ = try? await result.payloadValue.finish()
        }
        
        vm.isRestoring = false
    }
    
    private func loadTipProducts() async {
        do {
            let products = try await Product.products(for: [
                "supporter",
                "enthusiast",
                "legend"
            ])
            
            tipProducts = Array(products).sorted { p1, p2 in
                return p1.price < p2.price
            }
        } catch {
            print("Failed to load tip product:", error)
        }
    }
}
