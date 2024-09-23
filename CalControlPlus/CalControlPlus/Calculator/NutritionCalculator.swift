//
//  NutritionCalculator.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/22.
//

import Foundation
import FirebaseCore

class NutritionCalculator {
    
    static func calculateTotalNutrition(from records: [FoodRecord], for date: Date) -> TotalNutrition {
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
        
        return TotalNutrition(
            date: Timestamp(date: date),
            totalCalories: totalCalories.rounded(toPlaces: 1),
            totalCarbs: totalCarbs.rounded(toPlaces: 1),
            totalProtein: totalProtein.rounded(toPlaces: 1),
            totalFats: totalFats.rounded(toPlaces: 1)
        )
    }
    
    static func calculateWeeklyBudget(from records: [TotalNutrition], basicGoal: Int) -> Int {
        var weeklyTotalCal: Int = 0
        var weeklyTotalGoal = basicGoal * 7
        for record in records {
            weeklyTotalCal += Int(record.totalCalories)
        }
        return weeklyTotalGoal - weeklyTotalCal
    }
}
