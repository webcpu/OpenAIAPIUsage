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
    private var websiteItem: NSMenuItem?
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
        observeTokenUpdates()
        initiateWatchDog()
    }
    
    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    }
    
    private func setupMenuItems() {
        let statusBarMenu = NSMenu(title: "Menu")
        setupWebsiteItem(in: statusBarMenu)
        statusBarMenu.addItem(.separator())
        setupTokenDisplay(in: statusBarMenu)
        setupTokenActions(in: statusBarMenu)
        statusBarMenu.addItem(.separator())
        setupQuitItem(in: statusBarMenu)
        statusItem?.menu = statusBarMenu
    }
    
    private func setupWebsiteItem(in menu: NSMenu) {
        websiteItem = menu.addItem(
            withTitle: "3️⃣ Show Details",
            action: #selector(gotoWebsite),
            keyEquivalent: ""
        )
    }
    
    private func setupTokenDisplay(in menu: NSMenu) {
        let customView = createTokenDisplayView()
        let tokenMenuItem = NSMenuItem()
        tokenMenuItem.view = customView
        menu.addItem(tokenMenuItem)
    }
    
    private func setupTokenActions(in menu: NSMenu) {
        menu.addItem(
            withTitle: "1️⃣ Get Bearer Token",
            action: #selector(gotoWebsite),
            keyEquivalent: ""
        )
        
        menu.addItem(
            withTitle: "2️⃣ Paste Bearer Token",
            action: #selector(pasteBearerToken),
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
        let customView = NSView(frame: NSRect(x: 0, y: 0, width: 340, height: 20))
        let label = NSTextField(labelWithString: "Bearer Token")
        label.frame = NSRect(x: 12, y: 0, width: 100, height: 20)
        
        textField = NSTextField(frame: NSRect(x: 105, y: 0, width: 230, height: 20))
        textField.isEditable = false
        textField.stringValue = getBearerToken()
        
        customView.addSubview(label)
        customView.addSubview(textField)
        
        return customView
    }
    
    // MARK: - Token Management
    
    private func getBearerToken() -> String {
        return UserDefaults.standard.string(forKey: bearerTokenKey) ?? ""
    }
    
    private func setBearerToken(_ value: String) {
        UserDefaults.standard.set(value, forKey: bearerTokenKey)
    }
    
    private func observeTokenUpdates() {
        let hasToken = !getBearerToken().isEmpty
        statusItem?.button?.title = hasToken ? "Updating..." : "No Bearer Token"
        update()
    }
    
    private func initiateWatchDog() {
        WatchDog.shared.startRepeatingTimer(60) {
            self.update()
        }
    }
    
    // MARK: - Actions
    
    @objc private func gotoWebsite(sender: Any) {
        let urlString = "https://platform.openai.com/usage"
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }
    
    @objc private func pasteBearerToken(_ sender: AnyObject) {
        if let token = fetchTokenFromPasteboard() {
            let value = token.trimmingCharacters(in: .whitespacesAndNewlines)
            textField.stringValue = value
            setBearerToken(value)
            update()
        }
    }
    
    private func fetchTokenFromPasteboard() -> String? {
        let pasteboard = NSPasteboard.general
        if let text = pasteboard.string(forType: .string), text.hasPrefix("sess-") {
            return text
        }
        return nil
    }
    
    @objc private func quit(sender: AnyObject) {
        NSApplication.shared.terminate(self)
    }
    
    private func update() {
        let bearerToken = getBearerToken()
        guard !bearerToken.isEmpty else {
            return
        }
        
        Task {
            let amount = await API.getUsage(bearerToken)
            DispatchQueue.main.async {
                self.updateBillAmount(amount)
            }
        }
    }
    
    private func updateBillAmount(_ amount: Double?) {
        let title = amount != nil ?  String(format: "$%.2f", amount!/100.0) : "USD?"
        statusItem?.button?.title = title
    }
}
