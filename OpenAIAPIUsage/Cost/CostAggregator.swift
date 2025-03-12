/// A class that aggregates multiple usage fetchers and provides a total.
class CostAggregator {
    private var fetchers: [UsageFetcher]
    
    init(fetchers: [UsageFetcher]) {
        self.fetchers = fetchers
    }
    
    /// Returns a dictionary of usage per provider and a combined total.
    /// E.g. ["OpenAI": 123.0, "Anthropic": 456.0, "total": 579.0]
    func fetchAllUsages() async -> [String: Double] {
        var results = [String: Double]()
        var total: Double = 0
        
        for fetcher in fetchers {
            if let usage = await fetcher.fetchUsage() {
                results[fetcher.displayName] = usage
                total += usage
            }
        }
        if !results.isEmpty {
            results["total"] = total
        }
        return results
    }
}
