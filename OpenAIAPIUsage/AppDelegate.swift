//
//  AppDelegate.swift
//  OpenAIAPIUsage
//
//  Created by Liang on 20/02/2024.
//

import Foundation
import AppKit


class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private let bearerTokenKey = "BearerToken"
    private let anthropicCookieKey = "AnthropicCookie"
    private let anthropicOrganizationIDKey = "AnthropicOrganizationID"
    private var websiteItem: NSMenuItem?
    
    private var openAICostMenuItem: NSMenuItem?
    private var anthropicCostMenuItem: NSMenuItem?
    
    private var textField: NSTextField!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setup()
    }
}

//class MenuBar: NSObject {
extension AppDelegate {
    // MARK: - Setup
    
    func setup() {
        setupStatusBar()
        setupMenuItems()
        checkRequiredAuthData()
        initiateWatchDog()
    }
    
    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    }

    private func setupMenuItems() {
        let statusBarMenu = NSMenu(title: "Menu")
        
        setupOpenAIMenuItems(in: statusBarMenu)
        
        statusBarMenu.addItem(.separator())
        
        setupAnthropicMenuItems(statusBarMenu)
        
        statusBarMenu.addItem(.separator())
        
        setupHelpMenuItem(in: statusBarMenu)
        
        statusBarMenu.addItem(.separator())
        
        setupQuitItem(in: statusBarMenu)
        
        statusItem?.menu = statusBarMenu
    }
}

extension AppDelegate {
    fileprivate func setupAnthropicMenuItems(_ statusBarMenu: NSMenu) {
        setupAnthropicCostMenuItem(statusBarMenu)
        setupAnthropicCookieActions(in: statusBarMenu)
    }
    
    private func setupAnthropicCostMenuItem(_ statusBarMenu: NSMenu) {
        anthropicCostMenuItem = statusBarMenu.addItem(
            withTitle: "Anthropic Cost",
            action: #selector(gotoAnthropicWebsite),
            keyEquivalent: ""
        )
    }
    
    private func setupAnthropicCookieActions(in menu: NSMenu) {
        menu.addItem(
            withTitle: "1️⃣ Get Organization ID",
            action: #selector(gotoAnthropicOrganization),
            keyEquivalent: ""
        )
        
        menu.addItem(
            withTitle: "2️⃣ Paste Organization ID",
            action: #selector(pasteAnthropicOrganizationID),
            keyEquivalent: ""
        )
        
        menu.addItem(
            withTitle: "3️⃣ Get Cookie",
            action: #selector(gotoAnthropicWebsite),
            keyEquivalent: ""
        )
        
        menu.addItem(
            withTitle: "4️⃣ Paste Cookie",
            action: #selector(pasteAnthropicCookie),
            keyEquivalent: ""
        )
    }
}

extension AppDelegate {
    private func setupOpenAIMenuItems(in statusBarMenu: NSMenu) {
        openAICostMenuItem = statusBarMenu.addItem(
            withTitle: "OpenAI Cost",
            action: #selector(gotoOpenAIWebsite),
            keyEquivalent: ""
        )
        setupOpenAITokenActions(in: statusBarMenu)
    }
    
    private func setupOpenAIWebsiteItem(in menu: NSMenu) {
        menu.addItem(
            withTitle: "3️⃣ Show OpenAI Costs",
            action: #selector(gotoOpenAIWebsite),
            keyEquivalent: ""
        )
    }
    
    private func setupTokenDisplay(in menu: NSMenu) {
        let customView = createTokenDisplayView()
        let tokenMenuItem = NSMenuItem()
        tokenMenuItem.view = customView
        menu.addItem(tokenMenuItem)
    }
    
    private func setupOpenAITokenActions(in menu: NSMenu) {
        menu.addItem(
            withTitle: "1️⃣ Get Bearer Token",
            action: #selector(gotoOpenAIWebsite),
            keyEquivalent: ""
        )
        
        menu.addItem(
            withTitle: "2️⃣ Paste Bearer Token",
            action: #selector(pasteOpenAIBearerToken),
            keyEquivalent: ""
        )
    }
    
    private func setupHelpMenuItem(in menu: NSMenu) {
        menu.addItem(
            withTitle: "Help",
            action: #selector(gotoHelp),
            keyEquivalent: ""
        )
    }
    
    private func setupQuitItem(in menu: NSMenu) {
        menu.addItem(
            withTitle: "Quit",
            action: #selector(quit),
            keyEquivalent: ""
        )
    }
    
    private func createTokenDisplayView() -> NSView {
        let customView = NSView(frame: NSRect(x: 0, y: 0, width: 350, height: 20))
        let label = NSTextField(labelWithString: "Bearer Token: ")
        label.frame = NSRect(x: 12, y: 0, width: 100, height: 20)
        
        textField = NSTextField(frame: NSRect(x: 100, y: 0, width: 240, height: 20))
        textField.isEditable = false
        textField.isSelectable = false
        
        textField.stringValue = getBearerToken()
        
        customView.addSubview(label)
        customView.addSubview(textField)
        
        return customView
    }
}

extension AppDelegate {
    // MARK: - Token Management
    private func getBearerToken() -> String {
        return UserDefaults.standard.string(forKey: bearerTokenKey) ?? ""
    }
    
    private func setBearerToken(_ value: String) {
        UserDefaults.standard.set(value, forKey: bearerTokenKey)
    }
    
    private func getAnthropicOrganizationID() -> String {
        return UserDefaults.standard.string(forKey: anthropicOrganizationIDKey) ?? ""
    }
    
    private func setAnthropicOrgnizationID(_ value: String) {
        UserDefaults.standard.set(value, forKey: anthropicOrganizationIDKey)
    }
    
    private func getAnthropicCookie() -> String {
        return UserDefaults.standard.string(forKey: anthropicCookieKey) ?? ""
    }
    
    private func setAnthropicCookie(_ value: String) {
        UserDefaults.standard.set(value, forKey: anthropicCookieKey)
    }
    
    private func checkRequiredAuthData() {
        let hasToken = !getBearerToken().isEmpty
        statusItem?.button?.title = hasToken ? "Updating..." : "No Bearer Token"
        update()
       
        guard !getAnthropicOrganizationID().isEmpty else {
            statusItem?.button?.title = "No Anthropic Orgnization ID"
            return
        }
        guard !getAnthropicCookie().isEmpty else {
            statusItem?.button?.title = "No Anthropic Cookie"
            return
        }
        statusItem?.button?.title = "Updating..."
        update()
    }
    
    private func initiateWatchDog() {
        WatchDog.shared.startRepeatingTimer(60) {
            self.update()
        }
    }
    
    // MARK: - Actions
    @objc private func gotoHelp(sender: Any) {
        let urlString = "https://github.com/webcpu/OpenAIAPIUsage"
        openURL(urlString)
    }
    
    @objc private func gotoOpenAIWebsite(sender: Any) {
        let urlString = "https://platform.openai.com/usage"
        openURL(urlString)
    }
    
    @objc private func gotoAnthropicOrganization(sender: Any) {
        let urlString = "https://console.anthropic.com/settings/organization"
        openURL(urlString)
    }
    
    @objc private func gotoAnthropicWebsite(sender: Any) {
        let urlString = "https://console.anthropic.com/settings/cost"
        openURL(urlString)
    }
    
    @objc private func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }
    
    @objc private func pasteOpenAIBearerToken(_ sender: AnyObject) {
        if let token = fetchOpenAITokenFromPasteboard() {
            let value = token.trimmingCharacters(in: .whitespacesAndNewlines)
            setBearerToken(value)
            update()
        }
    }
    
    private func fetchOpenAITokenFromPasteboard() -> String? {
        let pasteboard = NSPasteboard.general
        if let text = pasteboard.string(forType: .string), text.hasPrefix("sess-") {
            return text
        }
        return nil
    }
    
    @objc private func pasteAnthropicOrganizationID(_ sender: AnyObject) {
        let pasteboard = NSPasteboard.general
        guard let text = pasteboard.string(forType: .string) else {
            return
        }
        let orgizationID = text.trimmingCharacters(in: .whitespacesAndNewlines)
        setAnthropicOrgnizationID(orgizationID)
        update()
    }
    
    @objc private func pasteAnthropicCookie(_ sender: AnyObject) {
        if let token = fetchAnthropicCookieFromPasteboard() {
            let value = token.trimmingCharacters(in: .whitespacesAndNewlines)
            setAnthropicCookie(value)
            update()
        }
    }
    
    private func fetchAnthropicCookieFromPasteboard() -> String? {
        let pasteboard = NSPasteboard.general
        if let text = pasteboard.string(forType: .string), text.contains("sessionKey=sk") {
            return text
        }
        return nil
    }
    
    @objc private func quit(sender: AnyObject) {
        NSApplication.shared.terminate(self)
    }
    
    private func update() {
        Task {
            async let cost1 = await getOpenAICost()
            async let cost2 = await getAnthropicCost()
            await updateCost(cost1, cost2)

        }
    }
    
    private func updateCost(_ cost1: Double?, _ cost2: Double?) async {
        var cost: Double? = nil
        if let cost1 {
            openAICostMenuItem?.title = String(format: "OpenAI Cost: $%.2f", cost1/100)
            cost = cost1
        }
        if let cost2 {
            anthropicCostMenuItem?.title = String(format: "Anthropic Cost: $%.2f", cost2/100)
            if cost == nil {
                cost = cost2
            } else {
                cost! += cost2
            }
        }
        await MainActor.run {[self] in
            self.updateTotalCost(cost)
        }
    }
    
    private func getOpenAICost() async -> Double? {
        let bearerToken = getBearerToken()
        guard !bearerToken.isEmpty else {
            return nil
        }
        
        return await API.getOpenAIUsage(bearerToken)
    }
    
    private func updateTotalCost(_ amount: Double?) {
        let title = amount != nil ?  String(format: "$%.2f", amount!/100.0) : "USD?"
        statusItem?.button?.title = title
    }
    
    private func getAnthropicCost() async -> Double? {
        let organizationID = getAnthropicOrganizationID()
        let cookie = getAnthropicCookie()
        guard !organizationID.isEmpty && !cookie.isEmpty else {
            return nil
        }
        
        return await API.getAnthropicUsage(cookie: cookie, organizationID: organizationID)
    }
}
