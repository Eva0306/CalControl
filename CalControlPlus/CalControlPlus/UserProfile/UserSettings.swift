//
//  UserSettings.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/19.
//

import Foundation
import FirebaseFirestore

struct UserSettings {
    var basicGoal: Int = 0
    var carbohydrateTotal: Double = 0
    var proteinTotal: Double = 0
    var fatTotal: Double = 0
}

struct User: Codable, Equatable {
    let id: String
    var status: UserStatus
    let createdTime: Timestamp
    let email: String?
    var name: String
    var avatarUrl: String?
    var gender: Gender
    var birthday: String // ISO8601 yyyy-MM-dd
    var height: Double
    var weightRecord: [WeightRecord]
    var activity: ActivityLevel
    var target: Target
    var totalNutrition: [TotalNutrition] // MAX item: 7
    var friends: [Friend]?
}

enum UserStatus: String, Codable, Equatable {
    case active = "active"
    case deleted = "deleted"
}

enum Gender: Int, Codable, CaseIterable, Equatable {
    case male = 0
    case female = 1
    
    func description() -> String {
        switch self {
        case .male:
            return "男性"
        case .female:
            return "女性"
        }
    }
}

enum ActivityLevel: Int, Codable, CaseIterable, Equatable {
    case sedentary = 0
    case light = 1
    case moderate = 2
    case active = 3
    case veryActive = 4
    
    func description() -> String {
        switch self {
        case .sedentary:
            return "身體活動趨於靜態"
        case .light:
            return "身體活動程度較低 "
        case .moderate:
            return "身體活動程度正常"
        case .active:
            return "身體活動程度較高"
        case .veryActive:
            return "身體活動程度激烈"
        }
    }
}

enum Target: Int, Codable, CaseIterable, Equatable {
    case loseWeight = 0
    case maintainWeight = 1
    case gainWeight = 2
    
    func description() -> String {
        switch self {
        case .loseWeight:
            return "減重"
        case .maintainWeight:
            return "維持"
        case .gainWeight:
            return "增重"
        }
    }
}

struct WeightRecord: Codable, Equatable {
    var date: Timestamp
    var weight: Double
}

struct TotalNutrition: Codable, Equatable {
    let date: Timestamp
    var totalCalories: Double
    var totalCarbs: Double // g
    var totalProtein: Double // g
    var totalFats: Double // g
    
    func toDictionary() -> [String: Any] {
        return [
            "date": date,
            "totalCalories": totalCalories,
            "totalCarbs": totalCarbs,
            "totalProtein": totalProtein,
            "totalFats": totalFats
        ]
    }
}

struct Friend: Codable, Equatable {
    let userID: String
    let addedAt: Timestamp
    let status: String
    var isFavorite: Bool
}
