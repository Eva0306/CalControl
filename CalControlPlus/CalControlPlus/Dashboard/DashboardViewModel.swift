//
//  DashboardViewModel.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/19.
//

import Foundation
import FirebaseCore

class DashboardViewModel: ObservableObject {
    @Published var foodRecords: [FoodRecord] = []
    @Published var totalNutrition: [TotalNutrition] = []
    
    var weeklyCaloriesData: [(day: String, value: Double)] = []
    var weeklyNutritionData: [WANutriData] = []
    
    var todayNutrition: [Double] {
        guard let todayData = weeklyNutritionData.last else {
            return [0.33, 0.33, 0.34]
        }
        return [todayData.carbohydrate, todayData.protein, todayData.fat]
    }
    
    let today = Calendar.current.startOfDay(for: Date())
    
    var maxCalories: Double {
        return totalNutrition.map { $0.totalCalories }.max() ?? 1.0
    }
    
    let userProfileViewModel: UserProfileViewModel
    
    init(userProfileViewModel: UserProfileViewModel) {
        self.userProfileViewModel = userProfileViewModel
    }
    
    func fetchTotalNutrition() {
        let startDate = Calendar.current.date(byAdding: .day, value: -6, to: today)!
        let endDate = Date()
        
        let startTimestamp = Timestamp(date: startDate)
        let endTimestamp = Timestamp(date: endDate)
        
        let conditions: [(String, FirestoreCondition, Any)] = [
            ("userID", .isEqualTo, userProfileViewModel.user.id),
            ("date", .isGreaterThanOrEqualTo, startTimestamp),
            ("date", .isLessThanOrEqualTo, endTimestamp)
        ]
        FirebaseManager.shared.getDocuments(
            from: .foodRecord, where: conditions
        ) { [weak self] (foodRecords: [FoodRecord]) in
            guard let self = self else {
                print("Couldn't find any Records")
                return
            }
            self.foodRecords = foodRecords
            calculateTotalNutrition()
        }
    }
    
    func calculateTotalNutrition() {
        var nutritionArray: [TotalNutrition] = []
        
        let groupedRecords = Dictionary(grouping: foodRecords) { record in
            Calendar.current.startOfDay(for: record.date!.dateValue())
        }
        
        for (date, records) in groupedRecords {
            var totalCalories: Double = 0
            var totalCarbs: Double = 0
            var totalProtein: Double = 0
            var totalFats: Double = 0
            
            for record in records {
                totalCalories += record.nutritionFacts.calories.value
                totalCarbs += record.nutritionFacts.carbs.value
                totalProtein += record.nutritionFacts.protein.value
                totalFats += record.nutritionFacts.fats.value
            }
            
            let totalNutritionForDay = TotalNutrition(
                date: Timestamp(date: date),
                totalCalories: totalCalories,
                totalCarbs: totalCarbs,
                totalProtein: totalProtein,
                totalFats: totalFats
            )
            
            nutritionArray.append(totalNutritionForDay)
        }
        
        self.totalNutrition = nutritionArray
        updateWeeklyCaloriesData()
        updateWeeklyNutritionData()
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"  // 例如 "Sun", "Mon"
        return formatter
    }()
    
    func updateWeeklyCaloriesData() {
        guard !totalNutrition.isEmpty else { return }
        
        weeklyCaloriesData = totalNutrition.map { nutrition -> (day: String, value: Double) in
            let dayString = dateFormatter.string(from: nutrition.date.dateValue())  // 格式化日期為 "Sun", "Mon" 等
            let normalizedValue = nutrition.totalCalories / maxCalories
            return (day: dayString, value: normalizedValue)
        }
    }
    
    func updateWeeklyNutritionData() {
        guard !totalNutrition.isEmpty else { return }
        
        weeklyNutritionData = totalNutrition.map { nutrition -> WANutriData in
            let dayString = dateFormatter.string(from: nutrition.date.dateValue())  // 格式化日期為 "Sun", "Mon" 等
            
            let totalNutrients = nutrition.totalCarbs + nutrition.totalFats + nutrition.totalProtein
            let carbohydrateRatio = totalNutrients > 0 ? (nutrition.totalCarbs / totalNutrients) : 0
            let fatRatio = totalNutrients > 0 ? (nutrition.totalFats / totalNutrients) : 0
            let proteinRatio = totalNutrients > 0 ? (nutrition.totalProtein / totalNutrients) : 0
            
            return WANutriData(
                day: dayString,
                carbohydrate: carbohydrateRatio,
                fat: fatRatio,
                protein: proteinRatio
            )
        }
    }
}
