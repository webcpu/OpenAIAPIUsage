//
//  WatchDog.swift
//  OpenAIAPIUsage
//
//  Created by Liang on 20/02/2024.
//

import Foundation

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
