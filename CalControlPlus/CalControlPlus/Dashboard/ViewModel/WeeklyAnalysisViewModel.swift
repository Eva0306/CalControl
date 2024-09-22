//
//  WeeklyAnalysisViewModel.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/22.
//

import Combine
import FirebaseFirestore
import SwiftUI

class WeeklyAnalysisViewModel: ObservableObject {
    @Published var basicGoal: Int = 0
    @Published var foodValue: Int = 0
    @Published var exerciseValue: Int = 0
    @Published var bargetValue: Int = 0 // Doing
    @Published var threshold: Double = 0
    @Published var weeklyCaloriesData: [(day: String, value: Double)] = []
    
    @Published var weeklyNutritionData: [WANutriData] = []
    @Published var todayNutrition: [Double] = []
    @Published var nutritionColors: [Color] = [.orange, .yellow, .blue]
    
    func update(from dashboardViewModel: DashboardViewModel, _ homeViewModel: HomeViewModel) {
        if let totalNutrition = homeViewModel.totalNutrition {
            self.basicGoal = homeViewModel.userProfileViewModel.userSettings.basicGoal
            self.foodValue = Int(totalNutrition.totalCalories)
            self.exerciseValue = homeViewModel.exerciseValue
            self.threshold = Double(self.basicGoal) / dashboardViewModel.maxCalories
            self.weeklyCaloriesData = dashboardViewModel.weeklyCaloriesData
            
            self.weeklyNutritionData = dashboardViewModel.weeklyNutritionData
            self.todayNutrition = dashboardViewModel.todayTotalNutrition
        }
    }
}
