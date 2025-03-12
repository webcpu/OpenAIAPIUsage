//
//  API.swift
//  OpenAIAPIUsage
//
//  Created by Liang on 20/02/2024.
//

import Foundation

struct API {
    static func getOpenAIUsage(_ bearerToken: String) async -> Double? {
        let (startDate, endDate) = getFirstDaysOfCurrentAndNextMonth() //getTodaysAndNextMonthsFirstDate()
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
    
    static func getAnthropicUsage(cookie: String, organizationID: String) async -> Double? {
        let (startDate, endDate) = getFirstDaysOfCurrentAndNextMonth() //getTodaysAndNextMonthsFirstDate()
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
            let string = String(data: data, encoding: .utf8)
            let decoder = JSONDecoder()
            let usage = try decoder.decode(CostData.self, from: data)
            return usage.totalCost
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    private static func getFirstDaysOfCurrentAndNextMonth() -> (String, String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let now = Date()
        let calendar = Calendar.current
        
        let currentMonthComponents = calendar.dateComponents([.year, .month], from: now)
        let startOfCurrentMonth = calendar.date(from: currentMonthComponents)!
        
        var nextMonthComponents = DateComponents()
        nextMonthComponents.month = 1
        let startOfNextMonth = calendar.date(byAdding: nextMonthComponents, to: startOfCurrentMonth)!
        
        return (dateFormatter.string(from: startOfCurrentMonth), dateFormatter.string(from: startOfNextMonth))
    }
    
    private static func getTodaysAndNextMonthsFirstDate() -> (today: String, firstDayOfNextMonth: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let today = Date()
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .current
        
        var components = DateComponents()
        components.month = 1
        components.day = -((calendar.component(.day, from: today) - 1))
        
        let firstDayNextMonth = calendar.date(byAdding: components, to: today)!
        
        // Reset to the first day of the next month
        let componentsForNextMonth = calendar.dateComponents([.year, .month], from: firstDayNextMonth)
        let firstDayOfNextMonth = calendar.date(from: componentsForNextMonth)!
        
        return (dateFormatter.string(from: today), dateFormatter.string(from: firstDayOfNextMonth))
    }
}
