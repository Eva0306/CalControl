//
//  HomeViewModel.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/19.
//

import Combine
import FirebaseFirestore
import HealthKit

var globalCurrentDate: Date = Calendar.current.startOfDay(for: Date())

class HomeViewModel: ObservableObject {
    
    static var shared = HomeViewModel()
    
    @Published var foodRecords: [FoodRecord] = []
    @Published var exerciseValue: Int = 0
    @Published var totalNutrition: TotalNutrition?
    @Published var currentDate: Date {
        didSet {
            globalCurrentDate = Calendar.current.startOfDay(for: currentDate)
            print("==== globalCurrentDate: ", globalCurrentDate)
            fetchFoodRecord(for: currentDate)
            addObserver(for: currentDate)
            fetchActiveEnergyBurned(for: currentDate)
        }
    }
    
    let mealCategories = ["早餐", "午餐", "晚餐", "點心"]
    
    private var cancellables = Set<AnyCancellable>()
    
    private let healthStore = HKHealthStore()
    
    var foodRecordsByCategory: [[FoodRecord]] {
        var categorizedRecords: [[FoodRecord]] = [[], [], [], []]
        
        for record in foodRecords {
            categorizedRecords[record.mealType].append(record)
        }
        return categorizedRecords
    }
    
    init() {
        self.currentDate = Calendar.current.startOfDay(for: Date())
        setupBindings()
        fetchFoodRecord(for: currentDate)
        addObserver(for: currentDate)
    }
    
    private func setupBindings() {
        $foodRecords
            .sink { [weak self] newRecords in
                guard let self = self else { return }
                self.recalculateTotalNutrition(from: newRecords)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - HealthKit Authorization
    func requestHealthKitAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data not available on this device.")
            return
        }
        
        let energyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        
        healthStore.requestAuthorization(toShare: nil, read: [energyType]) { success, error in
            DispatchQueue.main.async {
                if success {
                    print("HealthKit authorization succeeded.")
                    self.fetchActiveEnergyBurned(for: self.currentDate)
                } else {
                    if let error = error {
                        print("HealthKit authorization failed: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    // MARK: - Fetch Active Energy Burned
    func fetchActiveEnergyBurned(for date: Date) {
        let energyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        
        let startDate = Calendar.current.startOfDay(for: date)
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKStatisticsQuery(
            quantityType: energyType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { [weak self] (_, result, error) in
            guard let self = self else { return }
            
            var totalEnergyBurned: Double = 0
            
            if let sum = result?.sumQuantity() {
                totalEnergyBurned = sum.doubleValue(for: HKUnit.kilocalorie())
            }
            
            DispatchQueue.main.async {
                self.exerciseValue = Int(totalEnergyBurned)
            }
        }
        
        healthStore.execute(query)
    }

    // MARK: - Public Methods
    func fetchFoodRecord(for date: Date) {
        let conditions = generateQueryConditions(for: date)
        
        FirebaseManager.shared.getDocuments(
            from: .foodRecord,
            where: conditions
        ) { [weak self] (records: [FoodRecord]) in
            guard let self = self else { return }
            self.foodRecords = records
            self.totalNutrition = NutritionCalculator.calculateTotalNutrition(
                from: records,
                for: Calendar.current.startOfDay(for: date)
            )
        }
    }
    
    func addObserver(for date: Date) {
        
        FirebaseManager.shared.removeObservers(on: .foodRecord)
        
        let conditions = generateQueryConditions(for: date)
        
        FirebaseManager.shared.addObserver(
            on: .foodRecord,
            where: conditions
        ) { [weak self] (changeType: DocumentChangeType, foodRecord: FoodRecord) in
            guard let self = self else { return }
            switch changeType {
            case .added:
                self.foodRecords.append(foodRecord)
                
            case .modified:
                if let index = self.foodRecords.firstIndex(where: { $0.id == foodRecord.id }) {
                    self.foodRecords[index] = foodRecord
                }
                
            case .removed:
                if let index = self.foodRecords.firstIndex(where: { $0.id == foodRecord.id }) {
                    self.foodRecords.remove(at: index)
                }
            }
        }
    }
    
    private func generateQueryConditions(for date: Date) -> [FirestoreCondition] {
        let dateOnly = Calendar.current.startOfDay(for: date)
        let timestamp = Timestamp(date: dateOnly)
        
        return [
            FirestoreCondition(field: "userID", comparison: .isEqualTo, value: UserProfileViewModel.shared.user.id),
            FirestoreCondition(field: "date", comparison: .isEqualTo, value: timestamp)
        ]
    }
    
    private func recalculateTotalNutrition(from records: [FoodRecord]) {
        let dateOnly = Calendar.current.startOfDay(for: Date())
        self.totalNutrition = NutritionCalculator.calculateTotalNutrition(from: records, for: dateOnly)
    }
    
    func changeDate(to newDate: Date) {
        self.currentDate = Calendar.current.startOfDay(for: newDate)
    }
}
