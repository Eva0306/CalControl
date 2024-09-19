//
//  HomeViewModel.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/19.
//

import Combine
import FirebaseFirestore

class HomeViewModel: ObservableObject {
    @Published var foodRecords: [FoodRecord] = []
    @Published var exerciseValue: Int = 0
    
    var totalCalories: Double {
        return foodRecords.reduce(0.0) { result, record in
            result + record.nutritionFacts.calories.value
        }
    }
    
    var totalCarbs: Double {
        return foodRecords.reduce(0.0) { result, record in
            result + record.nutritionFacts.carbs.value
        }
    }
    
    var totalProtein: Double {
        return foodRecords.reduce(0.0) { result, record in
            result + record.nutritionFacts.protein.value
        }
    }
    
    var totalFats: Double {
        return foodRecords.reduce(0.0) { result, record in
            result + record.nutritionFacts.fats.value
        }
    }
    
    let userSettings: UserSettings
    
    init(userSettings: UserSettings) {
        self.userSettings = userSettings
    }
    
    func fetchFoodRecord(for date: Date) {
        let dateOnly = Calendar.current.startOfDay(for: date)
        let timestamp = Timestamp(date: dateOnly)
        
        FirebaseManager.shared.getDocuments(from: .foodRecord, where: "date", isEqualTo: timestamp) {
            [weak self] (records: [FoodRecord]) in
            guard let self = self else { return }
            self.foodRecords = records
        }
    }
}
