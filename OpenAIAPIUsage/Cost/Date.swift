//
//  API.swift
//  OpenAIAPIUsage
//
//  Created by Liang on 20/02/2024.
//

import Foundation

extension Date {
    static func getFirstDaysOfCurrentAndNextMonth() -> (String, String) {
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
    
    static func getTodaysAndNextMonthsFirstDate() -> (today: String, firstDayOfNextMonth: String) {
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
