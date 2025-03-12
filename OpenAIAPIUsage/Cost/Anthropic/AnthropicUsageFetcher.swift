//
//  AnthropicUsageFetcher.swift
//  OpenAIAPIUsage
//
//  Created by Liang on 12-03-2025.
//
import Foundation


class AnthropicUsageFetcher: UsageFetcher {
    private let tokenStorage: TokenStorage
    
    var displayName: String {
        "Anthropic"
    }
    
    init(tokenStorage: TokenStorage) {
        self.tokenStorage = tokenStorage
    }
    
    func fetchUsage() async -> Double? {
        let orgID = tokenStorage.getAnthropicOrganizationID()
        let cookie = tokenStorage.getAnthropicCookie()
        
        guard !orgID.isEmpty, !cookie.isEmpty else { return nil }
        
        // Example usage of the static API, or your own call:
        // return await API.getAnthropicUsage(cookie: cookie, organizationID: orgID)
        return await getAnthropicUsage(cookie: cookie, organizationID: orgID)
    }
    
    func getAnthropicUsage(cookie: String, organizationID: String) async -> Double? {
        let (startDate, endDate) = Date.getFirstDaysOfCurrentAndNextMonth() //getTodaysAndNextMonthsFirstDate()
        print(startDate, endDate)
        let urlString = "https://console.anthropic.com/api/organizations/\(organizationID)/usage_cost?starting_on=\(startDate)&ending_before=\(endDate)&group_by=workspace_id"
        guard let url = URL(string: urlString) else {
            print("Invalid urlString = \(urlString)")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(cookie, forHTTPHeaderField: "Cookie")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3", forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            let usage = try decoder.decode(CostData.self, from: data)
            return usage.totalCost
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
