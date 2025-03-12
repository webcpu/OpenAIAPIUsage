//
//  MenuBuilder.swift
//  OpenAIAPIUsage
//
//  Created by Liang on 12-03-2025.
//
import Cocoa

// MARK: - Menu Builder
/// Responsible for building the main menu, and wiring up the actions.
class MenuBuilder: NSObject {
    private let tokenStorage: TokenStorage
    
    // Keep references to dynamic menu items
    private var openAICostMenuItem: NSMenuItem?
    private var anthropicCostMenuItem: NSMenuItem?
    
    // Expose menu for external usage
    let menu: NSMenu = NSMenu(title: "Menu")
    
    // We'll use a callback so we can inform external code when user wants to update usage or open a URL
    var onUpdateRequested: (() -> Void)?
    var onOpenURLRequested: ((String) -> Void)?
    
    init(tokenStorage: TokenStorage) {
        self.tokenStorage = tokenStorage
        super.init()
        buildMenu()
    }
    
    private func buildMenu() {
        setupOpenAIMenuItems()
        menu.addItem(.separator())
        setupAnthropicMenuItems()
        menu.addItem(.separator())
        setupHelpMenuItem()
        menu.addItem(.separator())
        setupQuitMenuItem()
    }
    
    private func setupOpenAIMenuItems() {
        openAICostMenuItem = menu.addItem(
            withTitle: "OpenAI Cost: ?",
            action: #selector(didTapOpenAIUsage),
            keyEquivalent: ""
        )
        openAICostMenuItem?.target = self
        
        menu.addItem(
            withTitle: "1️⃣ Get Bearer Token",
            action: #selector(didTapOpenAIWebsite),
            keyEquivalent: ""
        ).target = self
        
        menu.addItem(
            withTitle: "2️⃣ Paste Bearer Token",
            action: #selector(didTapPasteOpenAIBearerToken),
            keyEquivalent: ""
        ).target = self
    }
    
    private func setupAnthropicMenuItems() {
        anthropicCostMenuItem = menu.addItem(
            withTitle: "Anthropic Cost: ?",
            action: #selector(didTapAnthropicUsage),
            keyEquivalent: ""
        )
        anthropicCostMenuItem?.target = self
        
        menu.addItem(
            withTitle: "1️⃣ Get Organization ID",
            action: #selector(didTapAnthropicOrganization),
            keyEquivalent: ""
        ).target = self
        
        menu.addItem(
            withTitle: "2️⃣ Paste Organization ID",
            action: #selector(didTapPasteAnthropicOrganizationID),
            keyEquivalent: ""
        ).target = self
        
        menu.addItem(
            withTitle: "3️⃣ Get Cookie",
            action: #selector(didTapAnthropicCostWebsite),
            keyEquivalent: ""
        ).target = self
        
        menu.addItem(
            withTitle: "4️⃣ Paste Cookie",
            action: #selector(didTapPasteAnthropicCookie),
            keyEquivalent: ""
        ).target = self
    }
    
    private func setupHelpMenuItem() {
        menu.addItem(
            withTitle: "Help",
            action: #selector(didTapHelp),
            keyEquivalent: ""
        ).target = self
    }
    
    private func setupQuitMenuItem() {
        menu.addItem(
            withTitle: "Quit",
            action: #selector(didTapQuit),
            keyEquivalent: ""
        ).target = self
    }
    
    // MARK: - Public Updaters
    /// Update the displayed cost in the menu items
    func updateCostDisplay(openAICost: Double?, anthropicCost: Double?) {
        if let openAICost {
            openAICostMenuItem?.title = String(format: "OpenAI Cost: $%.2f", openAICost / 100.0)
        } else {
            openAICostMenuItem?.title = "OpenAI Cost: ?"
        }
        
        if let anthropicCost {
            anthropicCostMenuItem?.title = String(format: "Anthropic Cost: $%.2f", anthropicCost / 100.0)
        } else {
            anthropicCostMenuItem?.title = "Anthropic Cost: ?"
        }
    }
    
    // MARK: - Selectors
    
    @objc private func didTapOpenAIUsage() {
        // Possibly navigate to usage page or trigger an update
        onOpenURLRequested?("https://platform.openai.com/usage")
    }
    
    @objc private func didTapOpenAIWebsite() {
        onOpenURLRequested?("https://platform.openai.com/usage")
    }
    
    @objc private func didTapPasteOpenAIBearerToken() {
        let pasteboard = NSPasteboard.general
        guard let text = pasteboard.string(forType: .string),
              text.hasPrefix("sess-") else {
            return
        }
        
        tokenStorage.setBearerToken(text.trimmingCharacters(in: .whitespacesAndNewlines))
        onUpdateRequested?()
    }
    
    @objc private func didTapAnthropicUsage() {
        onOpenURLRequested?("https://console.anthropic.com/settings/cost")
    }
    
    @objc private func didTapAnthropicOrganization() {
        onOpenURLRequested?("https://console.anthropic.com/settings/organization")
    }
    
    @objc private func didTapAnthropicCostWebsite() {
        onOpenURLRequested?("https://console.anthropic.com/settings/cost")
    }
    
    @objc private func didTapPasteAnthropicOrganizationID() {
        let pasteboard = NSPasteboard.general
        guard let text = pasteboard.string(forType: .string) else { return }
        
        tokenStorage.setAnthropicOrganizationID(text.trimmingCharacters(in: .whitespacesAndNewlines))
        onUpdateRequested?()
    }
    
    @objc private func didTapPasteAnthropicCookie() {
        let pasteboard = NSPasteboard.general
        guard let text = pasteboard.string(forType: .string),
              text.contains("sessionKey=sk") else {
            return
        }
        
        tokenStorage.setAnthropicCookie(text.trimmingCharacters(in: .whitespacesAndNewlines))
        onUpdateRequested?()
    }
    
    @objc private func didTapHelp() {
        onOpenURLRequested?("https://github.com/webcpu/OpenAIAPIUsage")
    }
    
    @objc private func didTapQuit() {
        NSApplication.shared.terminate(nil)
    }
}
