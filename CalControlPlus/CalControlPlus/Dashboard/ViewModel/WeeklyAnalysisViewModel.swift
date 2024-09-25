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
    @Published var bargetValue: Int = 0
    @Published var threshold: Double = 0
    @Published var weeklyCaloriesData: [(day: String, value: Double)] = []
    
    @Published var weeklyNutritionData: [WANutriData] = []
    @Published var todayNutrition: [Double] = []
    @Published var nutritionColors: [Color] = [.mainOrg, .mainBlue, .mainYellow]
    
    func update(from dashboardViewModel: DashboardViewModel, _ homeViewModel: HomeViewModel) {
        if let totalNutrition = homeViewModel.totalNutrition {
            let weeklyTotalCal = weeklyCaloriesData.reduce(0) { $0 + $1.value }
            
            self.basicGoal = UserProfileViewModel.shared.userSettings.basicGoal
            self.foodValue = Int(totalNutrition.totalCalories)
            self.exerciseValue = homeViewModel.exerciseValue
            self.bargetValue = self.basicGoal * 7 - Int(weeklyTotalCal)
            self.threshold = Double(self.basicGoal) / dashboardViewModel.maxCalories
            self.weeklyCaloriesData = dashboardViewModel.weeklyCaloriesData
            
            self.weeklyNutritionData = dashboardViewModel.weeklyNutritionData
            self.todayNutrition = dashboardViewModel.todayTotalNutrition
        }
    }
}
