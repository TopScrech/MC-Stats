import OSLog

private let logger = Logger()

extension ServerDetails {
    func deleteServer() {
        modelContext.delete(vm.server)
        
        do {
            try modelContext.save()
        } catch {
            // Failures include issues such as an invalid unique constraint
            logger.error("Error deleting server: \(error)")
        }
        
        refreshAllWidgets()
        
        refresh()
        dismiss()
    }
}
