import SwiftUI

struct PingGraphView: View {
    @Binding private var selectedElement: ServerPing?
    private let data: [ServerPing]
    private let average: Int

    init(_ data: [ServerPing], selectedElement: Binding<ServerPing?>, average: Int) {
        self.data = data
        _selectedElement = selectedElement
        self.average = average
    }

    // Seconds of history across the full width
    private let window: TimeInterval = 60

    // Render slightly in the past so new pings slide in from the edge instead of popping in
    private let delay: TimeInterval = 1.2

    private let graphHeight = 260.0
    private let lineColor: Color = .blue

    // Room for the axis labels on the trailing edge and half a label above the top grid line
    private let labelGutter = 44.0
    private let topInset = 8.0
    private let popoverSymbol = 0

    @State private var scale = PingGraphScale(100)
    @State private var width = 0.0

    // Round up to the next 50 ms step so the scale only changes on real jumps
    private var targetUpperBound: Double {
        let peak = data.map(\.ping).max() ?? 0
        return Double(max(100, (peak / 50 + 1) * 50))
    }

    var body: some View {
        TimelineView(.animation(paused: data.isEmpty)) { context in
            Canvas { ctx, size in
                let layout = PingGraphLayout(
                    size: plotSize(in: size),
                    end: context.date.addingTimeInterval(-delay),
                    window: window,
                    upperBound: scale.value(at: context.date)
                )

                ctx.translateBy(x: 0, y: topInset)

                drawGrid(in: &ctx, layout: layout)

                var plot = ctx
                plot.clip(to: Path(CGRect(x: 0, y: -topInset, width: layout.size.width, height: size.height)))

                drawLine(in: &plot, layout: layout)
                drawAverage(in: &plot, layout: layout)
                drawSelection(in: &plot, layout: layout)
            } symbols: {
                if let selectedElement {
                    PingChartPopover(selectedElement)
                        .tag(popoverSymbol)
                }
            }
        }
        .frame(height: graphHeight)
        .onGeometryChange(for: Double.self) {
            $0.size.width
        } action: {
            width = $0
        }
#if !os(tvOS)
        .contentShape(.rect)
        .gesture(selectionGesture)
#endif
        .onAppear {
            scale = PingGraphScale(targetUpperBound)
        }
        .onChange(of: targetUpperBound) { _, newValue in
            scale.animate(to: newValue)
        }
        .onChange(of: data.first?.id) {
            // Drop the selection once its ping falls out of the history
            if let selectedElement, !data.contains(where: { $0.id == selectedElement.id }) {
                self.selectedElement = nil
            }
        }
        .accessibilityElement()
        .accessibilityLabel("Ping graph")
        .accessibilityValue("Latest \(data.last?.ping ?? 0) ms, average \(average) ms")
    }

    // MARK: Drawing

    private func drawGrid(in ctx: inout GraphicsContext, layout: PingGraphLayout) {
        let step = gridStep(for: scale.target)
        var value = step

        while value <= layout.upperBound {
            let y = layout.y(for: value)

            var line = Path()
            line.move(to: CGPoint(x: 0, y: y))
            line.addLine(to: CGPoint(x: layout.size.width, y: y))

            ctx.stroke(line, with: .color(.gray.opacity(0.2)), lineWidth: 1)

            ctx.draw(
                Text("\(Int(value)) ms")
                    .font(.caption2)
                    .foregroundStyle(.secondary),
                at: CGPoint(x: layout.size.width + 6, y: y),
                anchor: .leading
            )

            value += step
        }

        var baseline = Path()
        baseline.move(to: CGPoint(x: 0, y: layout.size.height))
        baseline.addLine(to: CGPoint(x: layout.size.width, y: layout.size.height))

        ctx.stroke(baseline, with: .color(.gray.opacity(0.35)), lineWidth: 1)
    }

    private func drawLine(in ctx: inout GraphicsContext, layout: PingGraphLayout) {
        let points = data.map(layout.point)

        guard let first = points.first, let last = points.last else {
            return
        }

        let line = smoothPath(through: points)

        var area = line
        area.addLine(to: CGPoint(x: last.x, y: layout.size.height))
        area.addLine(to: CGPoint(x: first.x, y: layout.size.height))
        area.closeSubpath()

        ctx.fill(
            area,
            with: .linearGradient(
                Gradient(colors: [lineColor.opacity(0.35), lineColor.opacity(0.02)]),
                startPoint: .zero,
                endPoint: CGPoint(x: 0, y: layout.size.height)
            )
        )

        ctx.stroke(
            line,
            with: .color(lineColor),
            style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
        )

        // Dot on the newest ping
        let dot = CGRect(x: last.x - 3.5, y: last.y - 3.5, width: 7, height: 7)
        ctx.fill(Path(ellipseIn: dot), with: .color(lineColor))
    }

    private func drawAverage(in ctx: inout GraphicsContext, layout: PingGraphLayout) {
        guard !data.isEmpty else {
            return
        }

        let y = layout.y(for: Double(average))

        var line = Path()
        line.move(to: CGPoint(x: 0, y: y))
        line.addLine(to: CGPoint(x: layout.size.width, y: y))

        ctx.stroke(
            line,
            with: .color(.gray),
            style: StrokeStyle(lineWidth: 1, dash: [4, 4])
        )

        ctx.draw(
            Text("Avg")
                .font(.caption2)
                .foregroundStyle(.secondary),
            at: CGPoint(x: 2, y: y - 2),
            anchor: .bottomLeading
        )
    }

    private func drawSelection(in ctx: inout GraphicsContext, layout: PingGraphLayout) {
        guard let selectedElement else {
            return
        }

        let point = layout.point(for: selectedElement)

        var rule = Path()
        rule.move(to: CGPoint(x: point.x, y: 0))
        rule.addLine(to: CGPoint(x: point.x, y: layout.size.height))

        ctx.stroke(rule, with: .color(.gray.opacity(0.5)), lineWidth: 1)

        let dot = CGRect(x: point.x - 5, y: point.y - 5, width: 10, height: 10)
        ctx.fill(Path(ellipseIn: dot), with: .color(lineColor))
        ctx.stroke(Path(ellipseIn: dot), with: .color(.white), lineWidth: 2)

        if let popover = ctx.resolveSymbol(id: popoverSymbol) {
            let half = popover.size.width / 2
            let x = min(max(point.x, half), layout.size.width - half)

            ctx.draw(popover, at: CGPoint(x: x, y: 0), anchor: .top)
        }
    }

    // Quadratic curves through the midpoints, smooth without overshooting the data
    private func smoothPath(through points: [CGPoint]) -> Path {
        var path = Path()

        guard let first = points.first else {
            return path
        }

        path.move(to: first)

        for (previous, current) in zip(points, points.dropFirst()) {
            let mid = CGPoint(x: (previous.x + current.x) / 2, y: (previous.y + current.y) / 2)
            path.addQuadCurve(to: mid, control: previous)
        }

        if let last = points.last, points.count > 1 {
            path.addLine(to: last)
        }

        return path
    }

    private func plotSize(in size: CGSize) -> CGSize {
        CGSize(width: max(0, size.width - labelGutter), height: max(0, size.height - topInset))
    }

    private func gridStep(for upperBound: Double) -> Double {
        [25, 50, 100, 250, 500, 1000].first { upperBound / $0 <= 4 } ?? 2500
    }

    // MARK: Selection

#if !os(tvOS)
    private var selectionGesture: some Gesture {
        SpatialTapGesture()
            .onEnded {
                let element = findElement(atX: $0.location.x)

                // Clear the selection when tapping the same element
                selectedElement = selectedElement?.id == element?.id ? nil : element
            }
            .exclusively(
                before: DragGesture()
                    .onChanged {
                        selectedElement = findElement(atX: $0.location.x)
                    }
            )
    }

    private func findElement(atX x: CGFloat) -> ServerPing? {
        let layout = PingGraphLayout(
            size: plotSize(in: CGSize(width: width, height: graphHeight)),
            end: .now.addingTimeInterval(-delay),
            window: window,
            upperBound: scale.target
        )

        let date = layout.date(atX: x)

        return data.min {
            abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date))
        }
    }
#endif
}
