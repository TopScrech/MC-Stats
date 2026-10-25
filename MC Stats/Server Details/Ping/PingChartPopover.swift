import ScrechKit

struct PingChartPopover: View {
    private let ping: ServerPing

    init(_ ping: ServerPing) {
        self.ping = ping
    }

    var body: some View {
        VStack {
            Text(ping.date, format: .dateTime.hour().minute().second())
                .caption()
                .foregroundStyle(.secondary)

            Text("\(ping.ping) ms")
                .title3(.bold)
                .monospacedDigit()
        }
        .padding(8)
        // Solid fill, materials have nothing to blur when drawn as a Canvas symbol
        .background(.background.secondary, in: .rect(cornerRadius: 8))
        .accessibilityElement(children: .combine)
    }
}
