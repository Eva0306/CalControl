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

struct User: Codable {
    let id: String
    let createdTime: Timestamp
    var name: String
    var avatarUrl: String?
    var gender: Int
    var birthday: String // ISO8601 yyyy-MM-dd
    var height: Double
    var weightRecord: [WeightRecord]
    var activity: Int
    var target: Int
    var totalNutrition: [TotalNutrition] // MAX item: 7
    var friends: [Friend]?
}

struct WeightRecord: Codable {
    let createdTime: Timestamp
    let weight: Double
}

struct TotalNutrition: Codable {
    let createdTime: Timestamp
    var totalCalories: Double
    var totalCarbs: Double // g
    var totalProtein: Double // g
    var totalFats: Double // g
}

struct Friend: Codable {
    let userID: String
    let addedAt: Timestamp
    let status: String
}
