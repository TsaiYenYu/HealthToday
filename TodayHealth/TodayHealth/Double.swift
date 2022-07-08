//
//  Double.swift
//  TodayHealth
//
//  Created by user on 2022/7/7.
//


import Foundation

extension Double {
    
    public func decimalString(digit: Int = 0) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = digit
        return formatter.string(from: self as NSNumber)!
    }
    
    public func splitIntoParts(decimalPlaces: Int, round: Bool = true) -> (left: Int, right: Int) {
        var number = self
        if round {
            let divisor = pow(10.0, Double(decimalPlaces))
            number = Darwin.round(self * divisor) / divisor
        }
        let parts = String(format: "%.\(decimalPlaces)f", number).components(separatedBy: ".")

        let leftPart = Int(parts[0]) ?? 0
        let rightPart = Int(parts[1]) ?? 0

        return (leftPart, rightPart)
    }

}
