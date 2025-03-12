//
//  OpenAIUsageFetcher.swift
//  OpenAIAPIUsage
//
//  Created by Liang on 12-03-2025.
//

import Foundation

/// Fetcher for OpenAI usage.
class OpenAIUsageFetcher: UsageFetcher {
    private let tokenStorage: TokenStorage
    
    var displayName: String {
        "OpenAI"
    }
    
    init(tokenStorage: TokenStorage) {
        self.tokenStorage = tokenStorage
    }
    
    func fetchUsage() async -> Double? {
        let token = tokenStorage.getBearerToken()
        guard !token.isEmpty else { return nil }
        
        // Example usage of the static API, or your own call:
        // return await API.getOpenAIUsage(token)
        return await getOpenAIUsage(token)  // usage in cents
    }
    
    func getOpenAIUsage(_ bearerToken: String) async -> Double? {
        let (startDate, endDate) = Date.getFirstDaysOfCurrentAndNextMonth() //getTodaysAndNextMonthsFirstDate()
        print(startDate, endDate)
        let urlString = "https://api.openai.com/dashboard/billing/usage?end_date=\(endDate)&start_date=\(startDate)"
        guard let url = URL(string: urlString) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3", forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            let usage = try decoder.decode(Usage.self, from: data)
            return usage.totalUsage
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
