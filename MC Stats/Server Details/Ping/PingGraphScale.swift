import Foundation

// Time-based easing for the Y axis so rescaling glides instead of jumping
struct PingGraphScale {
    private var from: Double
    private var to: Double
    private var start = Date.distantPast
    private let duration = 0.45

    init(_ value: Double) {
        from = value
        to = value
    }

    var target: Double {
        to
    }

    func value(at date: Date) -> Double {
        let progress = min(1, max(0, date.timeIntervalSince(start) / duration))
        let eased = progress * progress * (3 - 2 * progress)

        return from + (to - from) * eased
    }

    mutating func animate(to target: Double, at date: Date = .now) {
        guard target != to else {
            return
        }

        from = value(at: date)
        to = target
        start = date
    }
}
