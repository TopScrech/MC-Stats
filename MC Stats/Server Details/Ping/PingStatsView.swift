import SwiftUI

struct PingStatsView: View {
    private let stats: PingStats

    init(_ stats: PingStats) {
        self.stats = stats
    }

    var body: some View {
        HStack {
            PingStatView("Min", value: stats.min)

            PingStatView("Avg", value: stats.average)

            PingStatView("Max", value: stats.max)

            PingStatView("Jitter", value: stats.jitter)
        }
    }
}
