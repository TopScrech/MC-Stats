import Foundation

@Observable
final class TipVM {
    var isRestoring = false
    var isProcessing = false
    var showAlert = false
    var alertTitle = ""
    var alertMessage = ""
}
