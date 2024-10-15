//
//  WeeklyNutriModel.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/19.
//

import Foundation
import SwiftUI

enum NutritionType: CaseIterable {
    case carbohydrate
    case protein
    case fat

    var color: Color {
        switch self {
        case .carbohydrate:
            return .mainOrg
        case .protein:
            return .mainBlue
        case .fat:
            return .mainYellow
        }
    }

    var displayName: String {
        switch self {
        case .carbohydrate:
            return "碳水化合物"
        case .protein:
            return "蛋白質"
        case .fat:
            return "脂肪"
        }
    }
}

struct WANutriData {
    var day: String
    var carbohydrate: Double
    var fat: Double
    var protein: Double
}

struct RecordCheckResult {
    var index: Int
    var weight: Double
}
