//
//  Date+Calendar.swift
//  TodayHealth
//
//  Created by user on 2022/7/7.
//

import Foundation

extension Date {
    public var startOfDay: Date {
        return Calendar.default.startOfDay(for: self)
    }

    public var startOfWeek: Date {
        let component = Calendar.default.dateComponents([.weekOfYear, .yearForWeekOfYear], from: self)
        return Calendar.default.date(from: component)!
    }
    
    public var startOfMonth: Date {
        var component = Calendar.default.dateComponents([.year, .month], from: self)
        component.day = 1
        return Calendar.default.date(from: component)!
    }
    
    public var startOfYear: Date {
        var components = Calendar.default.dateComponents([.year], from: self)
        components.month = 1
        components.day = 1
        return Calendar.default.date(from: components)!
    }
    
    public var startOfPreMonth: Date {
        var components = DateComponents()
        components.month = -2
        components.day = 1
        return Calendar.default.date(byAdding: components, to: self.startOfMonth)!
    }

    public var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.default.date(byAdding: components, to: startOfDay)!
    }

    public var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.default.date(byAdding: components, to: startOfMonth)!
    }
    
    public var endOfNextMonth: Date {
        var components = DateComponents()
        components.month = 2
        components.second = -1
        return Calendar.default.date(byAdding: components, to: self.startOfMonth)!
    }
    
    public var endOfPreWeek: Date {
        var components = DateComponents()
        components.second = -1
        return Calendar.default.date(byAdding: components, to: startOfWeek)!
    }
    
    public var startOfNextWeek: Date {
        var components = DateComponents()
        components.weekOfYear = 1
        return Calendar.default.date(byAdding: components, to: startOfWeek)!
    }
    
    public var startOfPreWeek: Date {
        var components = DateComponents()
        components.weekOfYear = -1
        return Calendar.default.date(byAdding: components, to: startOfWeek)!
    }
    
    public var daysOfMonth: [Date] {
        return daysInRange(start: self.startOfMonth, end: self.endOfMonth)
    }
    
    public var daysOfSeason: [Date] {
        return daysInRange(start: self.startOfPreMonth, end: self.endOfNextMonth)
    }
    
    public func daysInRange(start: Date, end: Date) -> [Date] {
        var temp = start
        var days = [temp]
        while temp < end {
            temp = Calendar.current.date(byAdding: .day, value: 1, to: temp)!
            days.append(temp)
        }
        return days
    }
    
    public var year: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: self)
    }
    
    public var month: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        return dateFormatter.string(from: self)
    }
    
    public var hour: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        return dateFormatter.string(from: self)
    }
    
    public var monthDayWeek: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.calendar = Calendar.current
        formatter.dateFormat = "MM月dd日 (EEEE)"
        return formatter.string(from: self)
    }
    
    public var yearMonthDayWeek: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.calendar = Calendar.current
        formatter.dateFormat = "yyyy年MM月dd日 (EEEE)"
        return formatter.string(from: self)
    }
    
    func isMonday() -> Bool {
        let components = Calendar.default.dateComponents([.weekday], from: self)
        return components.weekday == 2
    }
    
    public var lastMonth: Date {
        var components = DateComponents()
        components.month = -1
        return Calendar.default.date(byAdding: components, to: startOfMonth)!
    }
    
    public var nextMonth: Date {
        var components = DateComponents()
        components.month = 1
        return Calendar.default.date(byAdding: components, to: startOfMonth)!
    }
    
    public func isInSameMonth(date: Date) -> Bool {
        return isEqual(to: date, toGranularity: .month)
    }
    
    public func isEqual(to date: Date, toGranularity component: Calendar.Component, in calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, equalTo: date, toGranularity: component)
    }
}
