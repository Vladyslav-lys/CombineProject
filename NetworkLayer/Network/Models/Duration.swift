//
//  Duration.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 30.08.2022.
//

import Foundation

public struct Duration: Equatable {
    var milliseconds: Int
}

extension Duration {
    init(days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) {
        milliseconds =
            Duration.makeMilliseconds(days: days) +
            Duration.makeMilliseconds(hours: hours) +
            Duration.makeMilliseconds(minutes: minutes) +
            Duration.makeMilliseconds(seconds: seconds)
    }
    
    init(timeInterval: TimeInterval) {
        milliseconds = Int(timeInterval * 1000)
    }
    
    var timeInterval: TimeInterval {
        seconds
    }
    
    var seconds: Double {
        Double(milliseconds) / 1000
    }
    
    var wholeSeconds: Int {
        milliseconds / 1000
    }
    
    var minutes: Double {
        seconds / 60
    }
    
    var wholeMinutes: Int {
        wholeSeconds / 60
    }
    
    var hours: Double {
        minutes / 60
    }
    
    var wholeHours: Int {
        wholeMinutes / 60
    }
    
    var days: Double {
        hours / 24
    }
    
    var wholeDays: Int {
        wholeHours / 24
    }
    
    // MARK: - Private
    private static func makeMilliseconds(seconds: Int) -> Int {
        seconds * 1000
    }
    
    private static func makeMilliseconds(minutes: Int) -> Int {
        makeMilliseconds(seconds: minutes * 60)
    }
    
    private static func makeMilliseconds(hours: Int) -> Int {
        makeMilliseconds(minutes: hours * 60)
    }
    
    private static func makeMilliseconds(days: Int) -> Int {
        makeMilliseconds(hours: days * 24)
    }
}

extension Duration {
    static func + (lhs: Duration, rhs: Duration) -> Duration {
        Duration(milliseconds: lhs.milliseconds + rhs.milliseconds)
    }
}

// MARK: - Work with Date
extension Duration {
    func since(_ date: Date) -> Date {
        Date(timeInterval: timeInterval, since: date)
    }
    
    var sinceNow: Date {
        since(Date())
    }
}

// MARK: - Date convenience extension
extension Date {
    func durationSince(_ date: Date) -> Duration {
        Duration(timeInterval: timeIntervalSince(date))
    }
    
    var durationSinceNow: Duration {
        durationSince(Date())
    }
}

// MARK: - Int convenience extension
extension Int {
    var seconds: Duration {
        Duration(seconds: self)
    }
    
    var minutes: Duration {
        Duration(minutes: self)
    }
    
    var hours: Duration {
        Duration(hours: self)
    }
    
    var days: Duration {
        Duration(days: self)
    }
}
