//
//  CostData.swift
//  OpenAIAPIUsage
//
//  Created by Liang on 12-03-2025.
//


struct CostData: Codable {
    let costs: [String: [CostEntry]]
    
    enum CodingKeys: String, CodingKey {
        case costs = "costs"
    }
    // Computed property to sum up all the totals.
    var totalCost: Double {
        let cost = costs.values.flatMap { $0 }.reduce(0.0) { $0 + $1.total }
        return cost.rounded(.down)
    }
}

struct CostEntry: Codable {
    let workspaceId: String
    let modelName: String
    let total: Double
    let tokenType: String
    let promptTokenCountTier: String
    let usageType: String

    enum CodingKeys: String, CodingKey {
        case workspaceId = "workspace_id"
        case modelName = "model_name"
        case total
        case tokenType = "token_type"
        case promptTokenCountTier = "prompt_token_count_tier"
        case usageType = "usage_type"
    }
}
