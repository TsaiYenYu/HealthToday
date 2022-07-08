//
//  HealthViewModel.swift
//  TodayHealth
//
//  Created by user on 2022/7/7.
//

import Foundation
import Charts
import HealthKit

//決定時間 所得資料 更新畫面

class WalkingBarChartViewModel {
    
    var timeType: TimeUnit = .day
    private let todayDate = Date()
    private var model: HealthModel = HealthModel()
    var currentDate = Date()

    //MARK:: 更新UI
    var onSelectDate: ((String) -> ())?
    var onMainCount: ((String) -> ())?
    //圖表資料、X軸Label、步數
    var onChartDate: (([BarChartDataEntry], [String]) -> ())?
    var onWalkLocCalCard: ((String, String, String, TimeUnit) -> ())?
    var onTotalWalkLocCalCard: ((String, String, String, TimeUnit) -> ())?
    
    func selectTimeUnit(type: TimeUnit) {
        timeType = type
        model.timeType = type
        currentDate = todayDate
        switch timeType {
        case .day:
            onSelectDate?(currentDate.toString(dateFormat: "yyyy/MM/dd"))
        case .week:
            currentDate = todayDate.startOfWeek
            onSelectDate?(generateWeekDateString())
        case .month:
            onSelectDate?(currentDate.toString(dateFormat: "yyyy/MM"))
        }

        updateUI()
    }
    
    func onNextDate() {
        if currentDate >= todayDate { return }
        switch timeType {
        case .day:
            currentDate = currentDate.adding(.day, value: 1)
            onSelectDate?(currentDate.toString(dateFormat: "yyyy/MM/dd"))
        case .week:
            if currentDate >= todayDate.startOfWeek { return }
            currentDate = currentDate.adding(.day, value: 7)
            onSelectDate?(generateWeekDateString())
        case .month:
            currentDate = currentDate.adding(.month, value: 1)
            onSelectDate?(currentDate.toString(dateFormat: "yyyy/MM"))
        }
        updateUI()
    }
    
    func onLastDate() {
        switch timeType {
        case .day:
            currentDate = currentDate.adding(.day, value: -1)
            onSelectDate?(currentDate.toString(dateFormat: "yyyy/MM/dd"))
        case .week:
            currentDate = currentDate.adding(.day, value: -7)
            onSelectDate?(generateWeekDateString())
        case .month:
            currentDate = currentDate.adding(.month, value: -1)
            onSelectDate?(currentDate.toString(dateFormat: "yyyy/MM"))
        }
        updateUI()
    }
    
    func updateUI() {
        var fetchEndDay: Date = currentDate
        var countEndDay: Int = 0
        switch timeType {
        case .day:
            fetchEndDay = currentDate
            countEndDay = 1
        case .week:
            fetchEndDay = currentDate.adding(.day, value: 7)
            countEndDay = 8
        case .month:
            fetchEndDay = currentDate.endOfMonth
            countEndDay = fetchEndDay.daysOfMonth.count
        }

        model.updateData(currentDate: currentDate, fetchEndDay: fetchEndDay, numberOfDays: countEndDay, timeType: timeType) { modelData in
            self.onMainCount?( modelData.mainCountString )
            self.onWalkLocCalCard?( modelData.walkCount, modelData.locCount, modelData.calCount, modelData.timeType)
            self.onTotalWalkLocCalCard?( modelData.totalWalkCount, modelData.totalLocCount, modelData.totalCalCount, modelData.timeType)
            self.onChartDate?( modelData.barChartDataList, modelData.xAxisStringList )
        }
    }
}


extension WalkingBarChartViewModel {
    private func generateWeekDateString() -> String {
        let newStart = currentDate.toString(dateFormat: "yyyy/MM/dd")
        let newEndDay = currentDate.adding(.day, value: 6).toString(dateFormat: "yyyy/MM/dd")
        return newStart + " - " + newEndDay
    }
}
