//
//  Date+displayUtility.swift
//  TodayHealth
//
//  Created by user on 2022/7/7.
//


import Foundation

extension Date {
    public var daysSinceNow: Int {
        get {
            let interval = self.timeIntervalSinceNow
            if interval == 0 {
                return 0
            }
            return Int(interval) / (60 * 60 * 24)
        }
    }
    
    public var longString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.calendar = Calendar.current
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return formatter.string(from: self)
    }
    
    public var shortString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.calendar = Calendar.current
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: self)
    }
    
    public var showMonthString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.calendar = Calendar.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
    
    public var showMonth: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.calendar = Calendar.current
        formatter.dateFormat = "yyyy/MM"
        return formatter.string(from: self)
    }
    
    public var shortTime: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.calendar = Calendar.current
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
    
    public var completedString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.calendar = Calendar.current
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss.SSS"
        return formatter.string(from: self)
    }
    
    public var simpleDateFormat: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.calendar = Calendar.current
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: self)
    }
    
    public func toString(dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.init(identifier: "en_US")
        return dateFormatter.string(from: self)
    }
    
    public var dateTimeString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.calendar = Calendar.current
        formatter.dateFormat = "yyyyMMdd HH:mm:ss"
        return formatter.string(from: self)
    }
    
    public var logFormatString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.calendar = Calendar.current
        formatter.dateFormat = "yyyyMMddHHmmss.SSS"
        return formatter.string(from: self)
    }
    
    public func adding(_ component: Calendar.Component, value: Int) -> Date {
        return Calendar.default.date(byAdding: component, value: value, to: self)!
    }
}

public extension Calendar {
    static var `default`: Calendar = {
        var calendar = Calendar(identifier: .republicOfChina)
        calendar.firstWeekday = 1
        calendar.timeZone = TimeZone(identifier: "Asia/Taipei") ?? .autoupdatingCurrent
        calendar.locale = Locale(identifier: "zh_Hant_TW")
        return calendar
    }()
}
