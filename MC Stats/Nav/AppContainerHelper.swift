import Foundation
import MCStatsDataLayer
import OSLog

private let logger = Logger()

extension AppContainer {
    func refreshDisplayOrders() {
        servers?.enumerated().forEach { index, vm in
            vm.server.displayOrder = index + 1
            modelContext.insert(vm.server)
        }
        
        do {
            try modelContext.save()
        } catch {
            logger.error("Error saving display order: \(error)")
        }
    }
    
    func deleteItems(at offsets: IndexSet) {
        offsets.makeIterator().forEach { pos in
            if let serverVM = servers?[pos] {
#if !os(watchOS)
                if selectedServerID == serverVM.server.id {
                    selectedServerID = nil
                }
                serverVMCache.removeValue(forKey: serverVM.server.id)
#endif
                modelContext.delete(serverVM.server)
            }
        }
        
        do {
            try modelContext.save()
        } catch {
            logger.error("Error deleting servers: \(error)")
        }
        
        servers?.remove(atOffsets: offsets)
    }
    
    func checkForAutoReload() {
        let currentTime = Date()
        
        let timeInterval = currentTime.timeIntervalSince(lastRefreshTime)
        
        guard timeInterval > 60 else {
            return
        }
        
        // >60 seconds passed
        reloadData(forceRefresh: true)
        
        refreshAllWidgets()
    }
    
#if !os(watchOS)
    func checkForPendingDeepLink() {
        guard
            let pendingDeepLink,
            let serverID = UUID(uuidString: pendingDeepLink),
            let vm = serverVMCache[serverID]
        else {
            return
        }
        
        self.pendingDeepLink = nil
        goToServerView(vm)
    }
    
    func checkForAppReviewRequest() {
        reviewHelper.appLaunched()
        
        // Not showing if no servers were added
        if servers?.isEmpty ?? true {
            return
        }
        
        if reviewHelper.shouldShowRequestView() {
            Task {
                do {
                    try await Task.sleep(for: .seconds(6))
                } catch {
                    return
                }
                
#if !os(tvOS)
                requestReview()
#endif
                reviewHelper.didShowReview()
            }
        }
    }
    
    func goToServerView(_ vm: ServerStatusVM) {
        selectedServerID = UserDefaultsHelper.shared.get(for: .openToSpecificServer, defaultValue: true)
            ? vm.server.id : nil
    }
#endif
}
