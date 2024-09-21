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
    
    let userProfileViewModel: UserProfileViewModel
    
    let mealCategories = ["早餐", "午餐", "晚餐", "點心"]
    
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
    
    var foodRecordsByCategory: [[FoodRecord]] {
        var categorizedRecords: [[FoodRecord]] = [[], [], [], []]
        
        for record in foodRecords {
            switch record.mealType {
            case 0:
                categorizedRecords[0].append(record) // 早餐
            case 1:
                categorizedRecords[1].append(record) // 午餐
            case 2:
                categorizedRecords[2].append(record) // 晚餐
            case 3:
                categorizedRecords[3].append(record) // 點心
            default:
                break
            }
        }
        return categorizedRecords
    }
    
    init(userProfileViewModel: UserProfileViewModel) {
        self.userProfileViewModel = userProfileViewModel
    }
    
    func fetchFoodRecord(for date: Date) {
        let dateOnly = Calendar.current.startOfDay(for: date)
        let timestamp = Timestamp(date: dateOnly)
        
        FirebaseManager.shared.getDocuments(
            from: .foodRecord, where: [("date", timestamp)]
        ) { [weak self] (records: [FoodRecord]) in
            guard let self = self else { return }
            self.foodRecords = records
        }
    }
}
