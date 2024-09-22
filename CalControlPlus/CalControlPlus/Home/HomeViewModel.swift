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
    @Published var totalNutrition: TotalNutrition?
    
    let userProfileViewModel: UserProfileViewModel
    
    let mealCategories = ["早餐", "午餐", "晚餐", "點心"]
    
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
            from: .foodRecord, where: [("date", .isEqualTo, timestamp),
                                       ("userID", .isEqualTo, userProfileViewModel.user.id)]
        ) { [weak self] (records: [FoodRecord]) in
            guard let self = self else { return }
            self.foodRecords = records
            self.totalNutrition = NutritionCalculator.calculateTotalNutrition(from: records, for: dateOnly)
        }
    }
}
