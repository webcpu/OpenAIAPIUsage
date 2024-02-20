//
//  Usage.swift
//  OpenAIAPIUsage
//
//  Created by Liang on 20/02/2024.
//

import Foundation
struct Usage: Codable {
    let object: String
    let dailyCosts: [DailyCost]
    let totalUsage: Double
    
    enum CodingKeys: String, CodingKey {
        case object
        case dailyCosts = "daily_costs"
        case totalUsage = "total_usage"
    }
}

struct DailyCost: Codable {
    let timestamp: Double
    let lineItems: [LineItem]
    
    enum CodingKeys: String, CodingKey {
        case timestamp
        case lineItems = "line_items"
    }
}

struct LineItem: Codable {
    let name: String
    let cost: Double
}
