struct PingStats {
    let min: Int
    let max: Int
    let average: Int
    let jitter: Int

    init(_ data: [ServerPing]) {
        let pings = data.map(\.ping)

        min = pings.min() ?? 0
        max = pings.max() ?? 0
        average = pings.isEmpty ? 0 : pings.reduce(0, +) / pings.count

        // Mean absolute difference between consecutive pings
        let deltas = zip(pings, pings.dropFirst()).map { abs($1 - $0) }
        jitter = deltas.isEmpty ? 0 : deltas.reduce(0, +) / deltas.count
    }
}
