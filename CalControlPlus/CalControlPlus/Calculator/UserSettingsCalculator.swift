//
//  UserSettingsCalculator.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/23.
//

import Foundation

class UserSettingsCalculator {
    func setupUserSettings(user: User) -> UserSettings {
        let age = calculateAge(from: user.birthday)
        let bmr: Double
        
        let weight = user.weightRecord.last?.weight ?? 0
        
        if user.gender.rawValue == 0 {
            bmr = (13.7 * weight) + (5.0 * user.height) - (6.8 * Double(age)) + 66
        } else {
            bmr = (9.6 * weight) + (1.8 * user.height) - (4.7 * Double(age)) + 655
        }
        
        let activityFactor = getActivityFactor(activity: user.activity.rawValue)
        let tdee = Int(bmr * activityFactor)
        let basicGoal = transformToBasicGoal(tdee: tdee, target: user.target.rawValue)
        
        let carbohydrateTotal = Double(basicGoal.calories) * basicGoal.carbPercentage / 4.0
        let proteinTotal = Double(basicGoal.calories) * basicGoal.proteinPercentage / 4.0
        let fatTotal = Double(basicGoal.calories) * basicGoal.fatPercentage / 9.0
        
        return UserSettings(basicGoal: basicGoal.calories,
                            carbohydrateTotal: carbohydrateTotal,
                            proteinTotal: proteinTotal,
                            fatTotal: fatTotal)
    }
    
    private func calculateAge(from birthday: String) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let birthDate = formatter.date(from: birthday) else { return 0 }
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: Date())
        return ageComponents.year ?? 0
    }
    
    private func getActivityFactor(activity: Int) -> Double {
        switch activity {
        case 0: return 1.2   // 靜止不動
        case 1: return 1.375 // 輕度活動
        case 2: return 1.55  // 中度活動
        case 3: return 1.725 // 高度活動
        case 4: return 1.9   // 非常高度活動
        default: return 1.2  // 默認為靜止
        }
    }

    private func transformToBasicGoal(tdee: Int, target: Int) -> BasicGoal {
        switch target {
        case 0:
            return BasicGoal(calories: tdee - 500, proteinPercentage: 0.30, carbPercentage: 0.40, fatPercentage: 0.30)
        case 1:
            return BasicGoal(calories: tdee, proteinPercentage: 0.20, carbPercentage: 0.50, fatPercentage: 0.30)
        case 2:
            return BasicGoal(calories: tdee + 500, proteinPercentage: 0.20, carbPercentage: 0.50, fatPercentage: 0.30)
        default:
            return BasicGoal(calories: tdee, proteinPercentage: 0.20, carbPercentage: 0.50, fatPercentage: 0.30)
        }
    }
}
