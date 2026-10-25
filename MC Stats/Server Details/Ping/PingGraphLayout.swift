import Foundation

// Maps pings to points for a window of time that ends at `end`
struct PingGraphLayout {
    let size: CGSize
    let end: Date
    let window: TimeInterval
    let upperBound: Double

    private var start: Date {
        end.addingTimeInterval(-window)
    }

    func x(for date: Date) -> CGFloat {
        CGFloat(date.timeIntervalSince(start) / window) * size.width
    }

    func y(for ping: Double) -> CGFloat {
        size.height - CGFloat(min(ping, upperBound) / upperBound) * size.height
    }

    func point(for ping: ServerPing) -> CGPoint {
        CGPoint(x: x(for: ping.date), y: y(for: Double(ping.ping)))
    }

    func date(atX x: CGFloat) -> Date {
        start.addingTimeInterval(Double(x / size.width) * window)
    }
}
