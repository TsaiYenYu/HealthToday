//
//  HealthModel.swift
//  TodayHealth
//
//  Created by user on 2022/7/7.
//

import Foundation
import HealthKit
import Charts

struct HealthData {
    var selectDateString: String = "0"
    var mainCountString: String = "0"
    var barChartDataList: [BarChartDataEntry] = []
    var xAxisStringList: [String] = []
    var walkCount: String = "0"
    var locCount: String = "0"
    var calCount: String = "0"
    var totalWalkCount: String = "0"
    var totalLocCount: String = "0"
    var totalCalCount: String = "0"
    var timeType : TimeUnit = .day
}

class HealthModel {
    var timeType: TimeUnit = .day
    var healthStore = HKHealthStore()
    private let weekAxisStringList: [String] = ["週日", "週一", "週二", "週三", "週四", "週五", "週六"]

    init() {
        self.healthStore = HKHealthStore()
    }
        
    func updateData(currentDate: Date, fetchEndDay: Date, numberOfDays: Int, timeType: TimeUnit, complete: @escaping (HealthData) -> (Void))  {
        var dataModel = HealthData()
        HealthKitManager.current.fetchQuantityHealthDate(data: [.calory, .step, .distance],
                                                         date: fetchEndDay,
                                                         numberOfDays: numberOfDays)
        {
            switch $0 {
            case .success(let dataList):
                guard let list = dataList else {
                    complete(dataModel)
                    return
                }
                switch timeType {
                case .day:
                    guard let data = dataList?.first else {
                        complete(dataModel)
                        return
                    }
                    dataModel.mainCountString = data.steps.decimalString()
                    dataModel.walkCount = String(data.steps.decimalString())
                    dataModel.locCount = String(data.distance.decimalString())
                    dataModel.calCount = String(data.calories.decimalString())
                    dataModel.timeType = .day
                    self.getSumQuantityForOneDay(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!, date: fetchEndDay)
                    { doubleDataList in
                        dataModel.barChartDataList = self.generateDayBarChartData(fetchDay: currentDate, list: doubleDataList)
                        dataModel.xAxisStringList = self.generateDayXAxisList()
                        complete(dataModel)
                    }
                case .week:
                    let fixDataList = self.fillupMockDataByWeek(currentDate: currentDate, originList: list)
                    let totalData = self.totalStepDistanceCal(dataList: fixDataList)
                    dataModel.barChartDataList = self.generateWeekBarChartData(dataList: fixDataList)
                    dataModel.timeType = .week
                    dataModel.mainCountString = (totalData.0 / 7).decimalString()
                    dataModel.totalWalkCount = (totalData.0).decimalString()
                    dataModel.totalLocCount = (totalData.1).decimalString()
                    dataModel.totalCalCount = (totalData.2).decimalString()
                    dataModel.walkCount =   (totalData.0 / 7).decimalString()
                    dataModel.locCount =    (totalData.1 / 7).decimalString()
                    dataModel.calCount =    (totalData.2 / 7).decimalString()
                    dataModel.xAxisStringList = self.weekAxisStringList
                    complete(dataModel)
                case .month:
                    let fixDataList = self.fillupMockDataByMonth(currentDate: currentDate,  originList: list)
                    let totalData = self.totalStepDistanceCal(dataList: fixDataList)
                    let dayInMonth = Double(currentDate.startOfMonth.daysOfMonth.count)
                    dataModel.mainCountString = (totalData.0 / dayInMonth).decimalString()
                    dataModel.totalWalkCount  = (totalData.0).decimalString()
                    dataModel.totalLocCount   = (totalData.1).decimalString()
                    dataModel.totalCalCount   = (totalData.2).decimalString()
                    dataModel.walkCount       = (totalData.0 / dayInMonth).decimalString()
                    dataModel.locCount        = (totalData.1 / dayInMonth).decimalString()
                    dataModel.calCount        = (totalData.2 / dayInMonth).decimalString()
                    dataModel.xAxisStringList = self.generateMonXAxis(dayinMonth: Int(dayInMonth))
                    dataModel.barChartDataList = self.generateMonthBarChartData(dataList: fixDataList)
                    dataModel.timeType = .month
                    complete(dataModel)
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    func getSumQuantityForOneDay(_ quantity: HKQuantityType, date: Date, completionHandler: @escaping ([Double]) -> Void) {
        DispatchQueue(label: "healthFetch").asyncAfter(deadline: .now(), execute: {
            let semaphore = DispatchSemaphore(value: 0)
            let calendar = Calendar.current
            var doubleList: [Double] = []
            for i in 0...23 {
                let startOfDay = calendar.startOfDay(for: date).adding(.hour, value: i)
                let endOfDay = startOfDay.adding(.hour, value: 1)
                let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
                let query = HKStatisticsQuery(quantityType: quantity, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                    guard let result = result, let sum = result.sumQuantity() else {
                        doubleList.append(0)
                        if i >= 23 {
                            semaphore.signal()
                        }
                        return
                    }
                    let gg = sum.doubleValue(for: HKUnit.count())
                    doubleList.append(gg)
                    if i >= 23 {
                        semaphore.signal()
                    }
                }
                self.healthStore.execute(query)
            }
            semaphore.wait()
            completionHandler(doubleList)
        })
    }
    
    private func generateDayXAxisList() -> [String] {
        var xAxisStringList: [String] = []
        for i in 0...23 {
            if i == 0 {
                xAxisStringList.append("00:00")
            } else if i == 6 {
                xAxisStringList.append("06:00")
            } else if i == 12 {
                xAxisStringList.append("12:00")
            } else if i == 18 {
                xAxisStringList.append("18:00")
            } else if i == 23 {
                xAxisStringList.append("23:59")
            } else {
                xAxisStringList.append("")
            }
        }
        return xAxisStringList
    }
    
    private func generateDayBarChartData(fetchDay: Date, list: [Double]) -> [BarChartDataEntry] {
        var count = 0
        var barChartDataList: [BarChartDataEntry] = []
        list.forEach ({
            barChartDataList.append(
                BarChartDataEntry(x: Double(count), yValues: [$0], icon: nil, data: fetchDay.toString(dateFormat: "yyyy/MM/dd"))
            )
            count += 1
        })
        return barChartDataList
    }
    
    private func totalStepDistanceCal(dataList: [DailyQuantityTypeHealth]) -> (Double, Double, Double) {
        let allSteps = dataList.map {$0.steps}.reduce(0) { (partialResult, number) -> Double in
            return partialResult + number
        }
        
        let allDis = dataList.map {$0.distance}.reduce(0) { (partialResult, number) -> Double in
            return partialResult + number
        }
        
        let allCal = dataList.map {$0.calories}.reduce(0) { (partialResult, number) -> Double in
            return partialResult + number
        }
        return (allSteps, allDis, allCal)
    }
    
    private func fillupMockDataByWeek(currentDate: Date, originList: [DailyQuantityTypeHealth]) -> [DailyQuantityTypeHealth] {
        var newList: [DailyQuantityTypeHealth] = []
        var weekDayStringList: [String] = []
        for i in 0...6 {
            let currentDateString: String = currentDate.adding(.day, value: i).toString(dateFormat: "yyyy-MM-dd")
            weekDayStringList.append(currentDateString)
        }
        let dateStringList = originList.map{ $0.activityDate }
        weekDayStringList.forEach { mock in
            if dateStringList.contains(mock) {
                if let sameData = originList.first(where:{$0.activityDate == mock}) {
                    newList.append(sameData)
                }
            } else {
                let mockData = DailyQuantityTypeHealth(activityDate: mock,
                                                       steps: 0,
                                                       calories: 0,
                                                       distance: 0)
                newList.append(mockData)
            }
        }
        newList.forEach { it  in
            print(it.steps)
        }
        return newList
    }
    
    private func generateWeekBarChartData(dataList: [DailyQuantityTypeHealth]) -> [BarChartDataEntry] {
        var resultList: [BarChartDataEntry] = []
        var count: Int = 0
        dataList.forEach {
            let dateSplashString: String = $0.activityDate.toDate(format: "yyyy-MM-dd ")?.toString(dateFormat: "yyyy/MM/dd") ?? ""
            resultList.append(
                BarChartDataEntry(x: Double(count),
                                  yValues: [($0.steps)],
                                  icon: nil,
                                  data: dateSplashString)
                )
            count += 1
        }
        return resultList
    }
    
    private func fillupMockDataByMonth(currentDate: Date, originList: [DailyQuantityTypeHealth]) -> [DailyQuantityTypeHealth] {        var newList: [DailyQuantityTypeHealth] = []
        var weekDayStringList: [String] = []
        let startofDay = currentDate.startOfMonth
        for i in 0..<(startofDay.daysOfMonth.count - 1) {
            let currentDateString: String = startofDay.adding(.day, value: i).toString(dateFormat: "yyyy-MM-dd")
            weekDayStringList.append(currentDateString)
        }
        let dateStringList = originList.map{ $0.activityDate }
        weekDayStringList.forEach { mock in
            if dateStringList.contains(mock) {
                if let sameData = originList.first(where:{$0.activityDate == mock}) {
                    newList.append(sameData)
                }
            } else {
                let mockData = DailyQuantityTypeHealth(activityDate: mock,
                                                       steps: 0,
                                                       calories: 0,
                                                       distance: 0)
                newList.append(mockData)
            }
        }
        newList.forEach({ it in
            print(it.activityDate)
        })
        return newList
    }
    
    private func generateMonthBarChartData(dataList: [DailyQuantityTypeHealth]) -> [BarChartDataEntry] {
        var resultList: [BarChartDataEntry] = []
        var count: Int = 0
        dataList.forEach {
            let dateSplashString: String = $0.activityDate.toDate(format: "yyyy-MM-dd ")?.toString(dateFormat: "yyyy/MM/dd") ?? ""
            
            resultList.append(
                BarChartDataEntry(x: Double(count),
                                  yValues: [Double($0.steps)],
                                  icon: nil,
                                  data: dateSplashString)
            )
            count += 1
        }
        return resultList
    }
    
    private func generateMonXAxis(dayinMonth: Int) -> [String] {
        var resultList: [String] = []
        for i in 0...dayinMonth {
            if i == 1 {
                resultList.append("1日")
            } else if i == 8 {
                resultList.append("8日")
            } else if i == 15 {
                resultList.append("15日")
            } else if i == 22 {
                resultList.append("22日")
            } else {
                resultList.append("")
            }
        }
        return resultList
    }
 }
