//
//  String+utility.swift
//  TodayHealth
//
//  Created by user on 2022/7/7.
//

import Foundation

extension String {
    public func toDateforChineseDate(format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_Hant_TW")
        formatter.timeZone = TimeZone(identifier: "Asia/Taipei")
        formatter.calendar = Calendar(identifier: .republicOfChina)
        formatter.dateFormat = format
        
        return formatter.date(from: self)?.addingTimeInterval(8 * 60 * 60)
    }
    
    public func toDate(format: String) -> Date? {
        //yyyy-MM-dd'T'HH:mm:ss.SSSZ
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.calendar = Calendar.current
        formatter.dateFormat = format
        
        return formatter.date(from: self)
    }
    
    public func toDateUTC() -> Date? {
        return toDate(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
    }
    
    public func toDateUTCAdjust() -> Date? {
        return toDate(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")?.adding(.month, value: 1)
    }
}
