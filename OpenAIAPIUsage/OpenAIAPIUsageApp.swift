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
