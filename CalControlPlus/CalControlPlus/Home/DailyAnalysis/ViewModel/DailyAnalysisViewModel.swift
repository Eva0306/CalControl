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
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        bindToUserProfileViewModel()
    }
    
    private func bindToUserProfileViewModel() {
        UserProfileViewModel.shared.$userSettings
            .sink { [weak self] userSettings in
                guard let self = self else { return }
                self.basicGoal = userSettings!.basicGoal
                self.carbohydrateTotal = userSettings!.carbohydrateTotal
                self.proteinTotal = userSettings!.proteinTotal
                self.fatTotal = userSettings!.fatTotal
            }
            .store(in: &cancellables)
    }
    
    func update(from homeViewModel: HomeViewModel) {
        if let totalNutrition = homeViewModel.totalNutrition {
            self.foodValue = Int(totalNutrition.totalCalories)
            self.exerciseValue = homeViewModel.exerciseValue
            self.carbohydrateCurrent = totalNutrition.totalCarbs
            self.proteinCurrent = totalNutrition.totalProtein
            self.fatCurrent = totalNutrition.totalFats
        }
    }
}
