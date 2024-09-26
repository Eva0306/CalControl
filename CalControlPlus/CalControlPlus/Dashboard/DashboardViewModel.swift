//
//  DashboardViewModel.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/19.
//

import Foundation
import FirebaseCore

class DashboardViewModel: ObservableObject {
    @Published var weeklyTotalNutrition: [TotalNutrition] = []
    
    var foodRecords: [FoodRecord] = []
    
    var weeklyCaloriesData: [(day: String, value: Double)] = []
    var weeklyNutritionData: [WANutriData] = []
    
    let today = Calendar.current.startOfDay(for: Date())
    
    var todayTotalNutrition: [Double] {
        let todayString = dateFormatter.string(from: today)
        if let todayData = weeklyNutritionData.first(where: { $0.day == todayString }) {
            return [todayData.carbohydrate, todayData.protein, todayData.fat]
        }
        return [0, 0, 0] // Default values
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"  // 例如 "Sun", "Mon"
        return formatter
    }()
    
    var maxCalories: Double {
        return Double(UserProfileViewModel.shared.userSettings.basicGoal + 300) // BarChart max ratio
    }
    
    init() {
        
    }
    
    // MARK: - Public Methods
    
    func fetchWeeklyFoodRecords() {
        let conditions = generateQueryConditions()
        
        FirebaseManager.shared.getDocuments(
            from: .foodRecord, where: conditions
        ) { [weak self] (foodRecords: [FoodRecord]) in
            guard let self = self else { return }
            self.foodRecords = foodRecords
            self.processGroupedRecords(foodRecords: foodRecords)
        }
    }
    
    func addObserver() {
        let conditions = generateQueryConditions()
        
        FirebaseManager.shared.addObserver(
            on: .foodRecord,
            where: conditions
        ) { [weak self] (_: DocumentChangeType, _: FoodRecord) in
            guard let self = self else { return }
            self.fetchWeeklyFoodRecords()
        }
    }
    
    // MARK: - Private Methods
    private func generateQueryConditions() -> [FirestoreCondition] {
        let startDate = Calendar.current.date(byAdding: .day, value: -6, to: today)!
        let endDate = Date()
        
        let startTimestamp = Timestamp(date: startDate)
        let endTimestamp = Timestamp(date: endDate)
        
        return [
            FirestoreCondition(field: "userID", comparison: .isEqualTo, value: UserProfileViewModel.shared.user.id),
            FirestoreCondition(field: "date", comparison: .isGreaterThanOrEqualTo, value: startTimestamp),
            FirestoreCondition(field: "date", comparison: .isLessThanOrEqualTo, value: endTimestamp)
        ]
    }
    
    private func processGroupedRecords(foodRecords: [FoodRecord]) {
        let startDate = Calendar.current.date(byAdding: .day, value: -6, to: today)!
        let endDate = Date()
        
        let groupedRecords = Dictionary(grouping: foodRecords) { record in
            Calendar.current.startOfDay(for: record.date!.dateValue())
        }
        
        var weeklyNutritionData = self.generateEmptyNutritionData(startDate: startDate, endDate: endDate)
        
        for (date, records) in groupedRecords {
            let totalNutrition = NutritionCalculator.calculateTotalNutrition(from: records, for: date)
            if let index = weeklyNutritionData.firstIndex(
                where: { Calendar.current.isDate(
                    $0.date.dateValue(),
                    inSameDayAs: date
                ) }
            ) {
                weeklyNutritionData[index] = totalNutrition
            }
        }
        
        self.weeklyTotalNutrition = weeklyNutritionData.sorted(by: { $0.date.dateValue() < $1.date.dateValue() })
        self.updateWeeklyData()
        
        let docRef = FirestoreEndpoint.users.ref.document(UserProfileViewModel.shared.user.id)
        FirebaseManager.shared.setData(
            ["totalNutrition": self.weeklyTotalNutrition],
            at: docRef,
            merge: true
        )
    }
    
    private func generateEmptyNutritionData(startDate: Date, endDate: Date) -> [TotalNutrition] {
        var nutritionArray: [TotalNutrition] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            let emptyNutrition = TotalNutrition(
                date: Timestamp(date: currentDate),
                totalCalories: 0,
                totalCarbs: 0,
                totalProtein: 0,
                totalFats: 0
            )
            nutritionArray.append(emptyNutrition)
            
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return nutritionArray
    }
    
    private func updateWeeklyData() {
        guard !weeklyTotalNutrition.isEmpty else { return }
        
        var caloriesData: [(day: String, value: Double)] = []
        var nutritionData: [WANutriData] = []
        
        for nutrition in weeklyTotalNutrition {
            let dayString = dateFormatter.string(from: nutrition.date.dateValue())  // 格式化日期為 "Sun", "Mon" 等
            
            let normalizedCalories = nutrition.totalCalories / maxCalories
            caloriesData.append((day: dayString, value: normalizedCalories))
            
            let totalNutrients = nutrition.totalCarbs + nutrition.totalFats + nutrition.totalProtein
            let carbohydrateRatio = totalNutrients > 0 ? (nutrition.totalCarbs / totalNutrients) : 0
            let fatRatio = totalNutrients > 0 ? (nutrition.totalFats / totalNutrients) : 0
            let proteinRatio = totalNutrients > 0 ? (nutrition.totalProtein / totalNutrients) : 0
            
            let nutriData = WANutriData(
                day: dayString,
                carbohydrate: carbohydrateRatio,
                fat: fatRatio,
                protein: proteinRatio
            )
            nutritionData.append(nutriData)
        }
        
        weeklyCaloriesData = caloriesData
        weeklyNutritionData = nutritionData
    }
}
