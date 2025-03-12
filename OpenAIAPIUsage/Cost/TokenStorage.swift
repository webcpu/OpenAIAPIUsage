//
//  TokenStorage.swift
//  OpenAIAPIUsage
//
//  Created by Liang on 12-03-2025.
//
import Foundation

// MARK: - 1. Protocols

/// Defines how tokens/cookies are stored and retrieved.
protocol TokenStorage {
    func getBearerToken() -> String
    func setBearerToken(_ token: String)
    
    func getAnthropicOrganizationID() -> String
    func setAnthropicOrganizationID(_ id: String)
    
    func getAnthropicCookie() -> String
    func setAnthropicCookie(_ cookie: String)
}

/// Defines a contract for usage fetchers.
protocol UsageFetcher {
    /// Returns usage cost in cents (e.g. 123 means $1.23).
    func fetchUsage() async -> Double?
    /// A display name for the usage source.
    var displayName: String { get }
}

// MARK: - 2. Concrete Implementations

/// Concrete implementation of `TokenStorage` using `UserDefaults`.
class UserDefaultsTokenStorage: TokenStorage {
    private let bearerTokenKey = "BearerToken"
    private let anthropicCookieKey = "AnthropicCookie"
    private let anthropicOrganizationIDKey = "AnthropicOrganizationID"
    
    func getBearerToken() -> String {
        UserDefaults.standard.string(forKey: bearerTokenKey) ?? ""
    }
    
    func setBearerToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: bearerTokenKey)
    }
    
    func getAnthropicOrganizationID() -> String {
        UserDefaults.standard.string(forKey: anthropicOrganizationIDKey) ?? ""
    }
    
    func setAnthropicOrganizationID(_ id: String) {
        UserDefaults.standard.set(id, forKey: anthropicOrganizationIDKey)
    }
    
    func getAnthropicCookie() -> String {
        UserDefaults.standard.string(forKey: anthropicCookieKey) ?? ""
    }
    
    func setAnthropicCookie(_ cookie: String) {
        UserDefaults.standard.set(cookie, forKey: anthropicCookieKey)
    }
}
