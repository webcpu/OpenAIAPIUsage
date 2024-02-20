//
//  OpenAIAPIUsageApp.swift
//  OpenAIAPIUsage
//
//  Created by Liang on 20/02/2024.
//

import SwiftUI
import SwiftData

@main
struct OpenAIAPIUsageApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            Text("Settings")
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    let BEARER_TOKEN_KEY = "BearerToken"
    var statusItem: NSStatusItem?
    private var websiteItem: NSMenuItem?
    var textField: NSTextField!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        let statusBarMenu = NSMenu(title: "Menu")

        websiteItem = statusBarMenu.addItem(
            withTitle: "Show Details",
            action: #selector(gotoWebsite(sender:)),
            keyEquivalent: ""
        )
        
        statusBarMenu.addItem(.separator())

        let customView = NSView(frame: NSRect(x: 0, y: 0, width: 340, height: 20))
        
        let label = NSTextField(frame: NSRect(x: 12, y: 0, width: 100, height: 20))
        label.stringValue = "Bearer Token"
        label.isBezeled = false
        label.drawsBackground = false
        label.isEditable = false
        label.sizeToFit()
        
        textField = NSTextField(frame: NSRect(x: 105, y: 0, width: 230, height: 20))
        textField.isEditable = false
        textField.stringValue = getBearerToken()
        
        customView.addSubview(label)
        customView.addSubview(textField)
        
        let tokenMenuItem = NSMenuItem()
        tokenMenuItem.view = customView
        
        statusBarMenu.addItem(tokenMenuItem)
        
       statusBarMenu.addItem(
            withTitle: "Get Bearer Token" ,
            action: #selector(gotoWebsite(sender:)),
            keyEquivalent: ""
        )

        statusBarMenu.addItem(
            withTitle: "Paste Bearer Token",
            action: #selector(pasteBearerToken),
            keyEquivalent: ""
        )

        statusBarMenu.addItem(.separator())
        
        statusBarMenu.addItem(
            withTitle: "Quit",
            action: #selector(quit(sender:)),
            keyEquivalent: ""
        )
        statusItem?.menu = statusBarMenu
        
        statusItem?.button?.title = getBearerToken().isEmpty ? "No Bearer Token" : "Updating..."
        update()
        WatchDog.shared.startRepeatingTimer(60) {
            self.update()
        }
    }
    
    @objc func gotoWebsite(sender: Any) {
        let urlString = "https://platform.openai.com/usage"
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }
    
    func getBearerToken() -> String {
        return UserDefaults.standard.string(forKey: BEARER_TOKEN_KEY) ?? ""
    }
    
    func setBearerToken(_ value: String) {
        UserDefaults.standard.set(value, forKey: BEARER_TOKEN_KEY)
    }
    
    @objc func pasteBearerToken(_ sender: AnyObject) {
        if let token = fetchBearTokenFromNSPasteboard() {
            let value = token.trimmingCharacters(in: .whitespacesAndNewlines)
            textField.stringValue = value
            setBearerToken(value)
            update()
        }
    }
    
    private func fetchBearTokenFromNSPasteboard() -> String? {
        let pasteboard = NSPasteboard.general
        if let text = pasteboard.string(forType: .string), text.hasPrefix("sess-") {
            return text
        }
        return nil
    }
    
    @objc func quit(sender: AnyObject) {
        NSApplication.shared.terminate(self)
    }
    
    func update() {
        let bearerToken = getBearerToken()
        guard !bearerToken.isEmpty else {
            return
        }
        
        Task {
            let amount = await getUsage(bearerToken)
            DispatchQueue.main.async {
                self.updateBillAmount(amount)
            }
        }
    }
    
    func updateBillAmount(_ amount: Double?) {
        let title = amount != nil ?  String(format: "$%.2f", amount!/100.0) : "USD?"
        statusItem?.button?.title = title
    }
}

class WatchDog {
    static var shared: WatchDog = WatchDog()
    
    var timer: Timer?
    
    func startRepeatingTimer(_ interval: TimeInterval, action: @escaping () -> Void) {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            action()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

func getUsage(_ bearerToken: String) async -> Double? {
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

func getFirstDaysOfCurrentAndNextMonth() -> (String, String) {
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

func getTodaysAndNextMonthsFirstDate() -> (today: String, firstDayOfNextMonth: String) {
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

