//
//  DailyAnalysisViewModel.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/18.
//

import Combine
import Foundation
import WidgetKit

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
    
    var remainingValue: Int {
        return basicGoal - foodValue + exerciseValue
    }
    
    var progress: Double {
        let calculatedProgress = Double(remainingValue) / Double(basicGoal)
        
        if remainingValue > basicGoal {
            return calculatedProgress - 1.0
        } else if remainingValue <= 0 {
            return calculatedProgress
        } else {
            return (Double(basicGoal) - Double(remainingValue)) / Double(basicGoal)
        }
    }
    
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
        
        Publishers.CombineLatest4(
            $foodValue,
            $exerciseValue,
            $carbohydrateCurrent,
            $proteinCurrent
        )
        .combineLatest($fatCurrent)
        .sink { [weak self] _, _ in
            self?.saveDataToUserDefaults()
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
    
    func saveDataToUserDefaults() {
        let sharedDefaults = UserDefaults(suiteName: "group.com.calControl.widget")
        
        sharedDefaults?.set(basicGoal, forKey: "basicGoal")
        sharedDefaults?.set(foodValue, forKey: "foodValue")
        sharedDefaults?.set(exerciseValue, forKey: "exerciseValue")
        
        sharedDefaults?.set(remainingValue, forKey: "remainingValue")
        sharedDefaults?.set(progress, forKey: "progress")
        
        sharedDefaults?.set(carbohydrateCurrent, forKey: "carbohydrateCurrent")
        sharedDefaults?.set(carbohydrateTotal, forKey: "carbohydrateTotal")
        sharedDefaults?.set(proteinCurrent, forKey: "proteinCurrent")
        sharedDefaults?.set(proteinTotal, forKey: "proteinTotal")
        sharedDefaults?.set(fatCurrent, forKey: "fatCurrent")
        sharedDefaults?.set(fatTotal, forKey: "fatTotal")
        
        sharedDefaults?.synchronize()
        WidgetCenter.shared.reloadAllTimelines()
    }
}
