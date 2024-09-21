//
//  DailyAnalysisViewModel.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/18.
//

import Combine
import FirebaseFirestore

class DailyAnalysisViewModel: ObservableObject {
    @Published var basicGoal: Int = 0
    @Published var foodValue: Int = 0
    @Published var exerciseValue: Int = 0
    @Published var carbohydrateCurrent: Double = 0
    @Published var carbohydrateTotal: Double = 0
    @Published var proteinCurrent: Double = 0
    @Published var proteinTotal: Double = 0
    @Published var fatCurrent: Double = 0
    @Published var fatTotal: Double = 0
    
    func update(from homeViewModel: HomeViewModel) {
        self.basicGoal = homeViewModel.userProfileViewModel.userSettings.basicGoal
        self.foodValue = Int(homeViewModel.totalCalories)
        self.exerciseValue = homeViewModel.exerciseValue
        self.carbohydrateCurrent = homeViewModel.totalCarbs
        self.carbohydrateTotal = homeViewModel.userProfileViewModel.userSettings.carbohydrateTotal
        self.proteinCurrent = homeViewModel.totalProtein
        self.proteinTotal = homeViewModel.userProfileViewModel.userSettings.proteinTotal
        self.fatCurrent = homeViewModel.totalFats
        self.fatTotal = homeViewModel.userProfileViewModel.userSettings.fatTotal
    }
}
