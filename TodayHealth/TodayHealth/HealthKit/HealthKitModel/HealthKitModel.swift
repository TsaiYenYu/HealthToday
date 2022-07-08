//
//  HealthModel.swift
//  TodayHealth
//
//  Created by user on 2022/7/7.
//


import Foundation

typealias CompletionHealthHandler = (([DailyQuantityTypeHealth]?, [DailySleepInfo], Error?) -> Void)

public class DailyQuantityTypeHealth: Codable, Convertor {
    public var activityDate: String = ""
    public var steps: Double = 0
    public var calories: Double = 0
    public var distance: Double = 0.0
    
    public init(activityDate: String, steps: Double, calories: Double, distance: Double) {
        self.activityDate = activityDate
        self.steps = steps
        self.calories = calories
        self.distance = distance
    }
}

public class DailySleepInfo: Codable, Convertor {
    public var sleepStartTime: String = ""
    public var sleepEndtime: String = ""
    public var source: Sources = Sources()
}

public struct Sources: Codable, Convertor {
    var name: String = ""
    var version: String = ""
    var bundle: String = ""
    var productType: String = ""
    var operatingSystemVersion: String = ""
}

extension Date {
    public static func getDateFromString(_ strDate: String, format: String) -> Date {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = format

        return dateFormatter.date(from: strDate)!
    }

    public func getMinuteBetween(compareDate: Date) -> Int {
        let calendar = Calendar.current
        let date1 = calendar.dateComponents(in: TimeZone.current, from: self)
        let date2 = calendar.dateComponents(in: TimeZone.current, from: compareDate)

        let unitFlags = Set<Calendar.Component>([.second])
        let components = calendar.dateComponents(unitFlags, from: date1, to: date2)

        return components.second!
    }
}
