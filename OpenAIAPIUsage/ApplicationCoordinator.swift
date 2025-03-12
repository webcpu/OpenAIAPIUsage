//
//  ApplicationCoordinator.swift
//  OpenAIAPIUsage
//
//  Created by Liang on 12-03-2025.
//
import Cocoa

// MARK: - Main Application Coordinator
class ApplicationCoordinator {
    private let tokenStorage: TokenStorage
    private let menuBuilder: MenuBuilder
    private let aggregator: CostAggregator
    
    private var statusItem: NSStatusItem?
    
    init(tokenStorage: TokenStorage,
         fetchers: [UsageFetcher]) {
        self.tokenStorage = tokenStorage
        self.aggregator = CostAggregator(fetchers: fetchers)
        
        // Create the menu builder
        self.menuBuilder = MenuBuilder(tokenStorage: tokenStorage)
        // Setup callbacks
        self.menuBuilder.onUpdateRequested = { [weak self] in
            self?.update()
        }
        self.menuBuilder.onOpenURLRequested = { [weak self] urlString in
            self?.openURL(urlString)
        }
    }
    
    func start() {
        setupStatusItem()
        checkRequiredAuthData()
        WatchDog.shared.startRepeatingTimer(60) { [weak self] in
            self?.update()
        }
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.menu = menuBuilder.menu
        statusItem?.button?.title = "Loading..."
        update()
    }
    
    private func checkRequiredAuthData() {
        let hasOpenAIBearer = !tokenStorage.getBearerToken().isEmpty
        let hasAnthropicOrg = !tokenStorage.getAnthropicOrganizationID().isEmpty
        let hasAnthropicCookie = !tokenStorage.getAnthropicCookie().isEmpty
        
        // Update status bar as a hint.
        if !hasOpenAIBearer {
            statusItem?.button?.title = "No Bearer Token"
        } else if !hasAnthropicOrg {
            statusItem?.button?.title = "No Anthropic Org ID"
        } else if !hasAnthropicCookie {
            statusItem?.button?.title = "No Anthropic Cookie"
        } else {
            statusItem?.button?.title = "Updating..."
        }
    }
    
    private func update() {
        Task {
            let usages = await aggregator.fetchAllUsages()
            await MainActor.run { [weak self] in
                self?.updateUI(with: usages)
            }
        }
    }
    
    @MainActor
    private func updateUI(with usages: [String: Double]) {
        // Update menu items
        let openAIValue = usages["OpenAI"]
        let anthropicValue = usages["Anthropic"]
        menuBuilder.updateCostDisplay(openAICost: openAIValue, anthropicCost: anthropicValue)
        
        // Update status item with total if available
        if let total = usages["total"] {
            let display = String(format: "$%.2f", total / 100.0)
            statusItem?.button?.title = display
        } else {
            // If no total, we can show ? or something else
            statusItem?.button?.title = "USD?"
        }
    }
    
    private func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }
}
