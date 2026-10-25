import ScrechKit

struct PingStatView: View {
    private let title: LocalizedStringKey
    private let value: Int

    init(_ title: LocalizedStringKey, value: Int) {
        self.title = title
        self.value = value
    }

    var body: some View {
        VStack {
            Text(title)
                .caption()
                .foregroundStyle(.secondary)

            Text("\(value) ms")
                .headline(.semibold)
                .monospacedDigit()
                .contentTransition(.numericText(value: Double(value)))
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .animation(.default, value: value)
    }
}
