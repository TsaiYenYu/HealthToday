//
//  HealthManager.swift
//  TodayHealth
//
//  Created by user on 2022/7/7.
//


import HealthKit

extension UserDefaults {
    public var healthAuthorizeStatus: Bool {
        set {
            setValue(newValue, forKey: "alreadyAskHealth")
            synchronize()
        }
        get {
            return bool(forKey: "alreadyAskHealth")
        }
    }
}

public enum HealthkitError: Error {
    case notAvailableOnDevice
    case dataTypeNotAvailable
    case deniedAuthorization
}

public enum QuantityHealthKind: CaseIterable {
    case step
    case calory
    case distance
    
    var infoTypeIdentifier: HKQuantityTypeIdentifier {
        switch self {
        case .step: return .stepCount
        case .calory: return .activeEnergyBurned
        case .distance: return .distanceWalkingRunning
        }
    }
    
    var unit: HKUnit {
        switch self {
        case .step: return .count()
        case .calory: return .kilocalorie()
        case .distance: return .meter()
        }
    }
}

public class HealthKitManager: NSObject {
    
    var recordDate: String = ""
    let healthKitStore: HKHealthStore = HKHealthStore()
    public var healthAuthStatus: Bool {
        if healthQuantityData.isEmpty && sleepData.isEmpty {
            return false
        }  else {
            return true
        }
    }
    
    private var sleepData: [DailySleepInfo] = []
    private var healthQuantityData: [DailyQuantityTypeHealth] = []
    
    private struct Static {
        static var instance: HealthKitManager!
    }
    
    public static var current : HealthKitManager = {
        let queue = DispatchQueue(label: "once")
        queue.sync {
            Static.instance = HealthKitManager()
        }
        return Static.instance
    }()
    
    
    // MARK: authorizeHealthKit
    public func authorizeHealthKit(completion: @escaping (Result<Bool, HealthkitError>) -> ()) {
        //health data we want to read from HealthKit.
        let healthDataToRead = readDataType()

        guard HKHealthStore.isHealthDataAvailable() else {
            completion(.failure(.notAvailableOnDevice))
            return
        }
        
        guard let _ = healthDataToRead else {
            completion(.failure(.dataTypeNotAvailable))
            return
        }
        
        healthKitStore.requestAuthorization(toShare: nil, read: healthDataToRead) { (success, error) in
            OperationQueue.main.addOperation {
                if success {
                    debugPrint("User was shown permission view")
                    return completion(.success(success))
                } else {
                    debugPrint("User was not shown permission view")
                    return completion(.failure(.dataTypeNotAvailable))
                }
            }
        }
    }
    
    private func readDataType() -> Set<HKObjectType>? {
        var readObjectTypes: Set<HKObjectType>?
        if  let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount),
            let distance = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning),
            let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
            let sleep = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)  {
            readObjectTypes = Set(arrayLiteral: stepCount, distance, activeEnergy, sleep)
        }
        return readObjectTypes
    }
    
    public func fetchQuantityHealthDate(data type: [QuantityHealthKind], date: Date, numberOfDays: Int = 1, completion: @escaping ((Result<[DailyQuantityTypeHealth]?, Error>) -> Void)) {
        let endDate = date
        let startDate = endDate.getDateFromNow(whenDifferenceInDays: numberOfDays)!

        // reset data
        healthQuantityData = []
        getQuitytyData(From: startDate, To: endDate, data: type) { completion($0) }
    }

    // MARK: getQuitytyData
    func getQuitytyData(From startDate: Date, To endDate: Date, data healthType: [QuantityHealthKind], completion: @escaping ((Result<[DailyQuantityTypeHealth]?, Error>) -> Void)) {
        
        guard let type = healthType.first else {
            completion(.success(healthQuantityData))
            return
        }
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: type.infoTypeIdentifier) else { return }
        retrieveCollectionQueryData(sample: quantityType,
                                    healthType: type,
                                    startDate: startDate,
                                    endDate: endDate) {  [self] res in
            switch res {
            case .success(let list):
                if let list = list {
                    list.forEach { data in
                        if let _ = healthQuantityData.first(where: { health in
                            return health.activityDate == data.date
                        }) {
                            healthQuantityData = healthQuantityData.compactMap {
                                if $0.activityDate == data.date {
                                    switch data.kind {
                                    case .calory:
                                        $0.calories = data.value
                                    case .distance:
                                        $0.distance = data.value
                                    case .step:
                                        $0.steps = data.value
                                    }
                                }
                                return $0
                            }
                        } else {
                            let quantityType = DailyQuantityTypeHealth(activityDate: "", steps: 0, calories: 0, distance: 0)
                            quantityType.activityDate = data.date
                            
                            switch data.kind {
                            case .calory:
                                quantityType.calories = data.value
                            case .distance:
                                quantityType.calories = data.value
                            case .step:
                                quantityType.steps = data.value
                            }
                            healthQuantityData.append(quantityType)
                        }
                    }
                }
            case .failure(let error):
                debugPrint(error.localizedDescription)
            }
            var types = healthType
            types.removeFirst()
            self.getQuitytyData(From: startDate, To: endDate, data: types, completion: completion)
        }
    }
    
    // MARK: fetchSleep
    public func fetchSleepData(date: Date, numberOfDays: Int = 1, completion: @escaping ((Result<[DailySleepInfo]?, Error>) -> Void)) {
        let endDate = date
        let startDate =  Date(timeInterval: TimeInterval(-24 * 60 * 60 * numberOfDays), since: endDate)
        
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }
        retrieveSleepAnalysis(sleepType: sleepType, startDate: startDate, endDate: endDate) { completion($0) }
    }
    
    
    func retrieveCollectionQueryData(sample: HKQuantityType, healthType: QuantityHealthKind, startDate: Date, endDate: Date, completion: @escaping(Result<[(date: String, kind: QuantityHealthKind, value: Double)]?, Error>) -> ()) {
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        var interval = DateComponents()
        interval.day = 1
        let query = HKStatisticsCollectionQuery(quantityType: sample,
                                                quantitySamplePredicate: predicate,
                                                options: [.cumulativeSum],
                                                anchorDate: startDate,
                                                intervalComponents: interval)
        
        query.initialResultsHandler = { query, results, error in
            guard let results = results else {
                completion(.failure(HealthkitError.notAvailableOnDevice))
                return
            }
            
            var data: [(String, QuantityHealthKind, Double)] = []
            results.enumerateStatistics(from: startDate, to: endDate) { statistics, stop in
                if let quantity = statistics.sumQuantity() {
                    let value = quantity.doubleValue(for: healthType.unit)
                    data.append((date: statistics.startDate.showMonthString, kind: healthType, value: value))

                }
            }
            print("query.initialResultsHandler  \(data)")
            completion(.success(data))
        }
        healthKitStore.execute(query)
    }
        
    func retrieveSleepAnalysis(sleepType: HKSampleType, startDate: Date, endDate: Date, completion: @escaping (Result<[DailySleepInfo]?, Error>) -> ()) {
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { [weak self] (query, result, error) in
            guard let self = self else { return }
            
            guard let result = result else {
                completion(.failure(HealthkitError.notAvailableOnDevice))
                debugPrint("Error fetching results: \(String(describing: error))")
                return
            }
            
            var data: [DailySleepInfo] = []
            self.getAsleepSample(data: &data, from: result)
            self.sleepData = data
            completion(.success(data))
        }
        healthKitStore.execute(query)
    }
    
    private func getAsleepSample(data: inout [DailySleepInfo], from statisticsCollection: [HKSample]) {
        let asleepArr = statisticsCollection.filter { (sample) -> Bool in
            let sample = sample as! HKCategorySample
            return (sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue)
        }
        
        asleepArr.forEach({ (sample) in
            let sample = sample as! HKCategorySample
            let sleepInfos = DailySleepInfo()
            sleepInfos.sleepStartTime = sample.startDate.convertTaiwanDateFormatter
            sleepInfos.sleepEndtime = sample.endDate.convertTaiwanDateFormatter
//            sleepInfos.sources.type = HKCategoryValueSleepAnalysis(rawValue: sample.value)?.string
            sleepInfos.source.bundle = sample.sourceRevision.source.bundleIdentifier
            sleepInfos.source.name = sample.sourceRevision.source.name
            sleepInfos.source.operatingSystemVersion = sample.sourceRevision.version ?? "Unknown"
            if #available(iOS 11.0, *) {
                sleepInfos.source.productType = sample.sourceRevision.productType ?? "Unknown"
            } else {
                sleepInfos.source.productType = "UnAvailable"
            }
            data.append(sleepInfos)
        })
    }
}

extension Date {
    public var convertTaiwanDateFormatter: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm:ss.SSS"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Taipei")
        return dateFormatter.string(from: self)
    }
    
    public func getDateFromNow(whenDifferenceInDays days: Int) -> Date? {
        let calendar = Calendar.current
        guard let date = calendar.date(byAdding: .day, value: -(days - 1), to: self) else {
            return nil
        }
        return calendar.startOfDay(for: date)
    }
}

extension String {
    public var convertToDate: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return dateFormatter.date(from: self)!
    }
}

extension HKCategoryValueSleepAnalysis {
    var string: String {
        if #available(iOS 10.0, *) {
            switch self {
            case .inBed:
                return "inBed"
            case .asleep:
                return "asleep"
            case .awake:
                return "awake"
            default:
                return "Unknown"
            }
        } else {
            switch self {
            case .inBed:
                return "inBed"
            case .asleep:
                return "asleep"
            default:
                return "Unknow"
            }
        }
    }
}
