//
//  Model.swift
//  FoodClassifier
//
//  Created by 楊芮瑊 on 2024/9/9.
//

// MARK: - Firestore Struct
import FirebaseFirestore

struct FoodRecord: Codable {
    let id: String
    let user_id: String
    let date: Timestamp
    let nutritionFacts: NutritionFacts
    let imageUrl: String?
}

// MARK: - Classify Type
enum ClassifyType: String {
    case food
    case nutritionFact
}

// MARK: - Nutrition Facts
struct Nutrient: Codable {
    let value: Double
    let unit: String
}

struct NutritionFacts: Codable {
    var title: String?
    var mealType: Int
    let weight: Nutrient
    let calories: Nutrient
    let carbs: Nutrient
    let fats: Nutrient
    let protein: Nutrient
}

// MARK: - Response
struct NutritionResponse: Codable {
    let uri: String
    let calories: Double
    let totalCO2Emissions: Double
    let co2EmissionsClass: String
    let totalWeight: Double
    let dietLabels, healthLabels: [String]
    let totalNutrients, totalDaily: [String: TotalDaily]
    let ingredients: [Ingredient]?
    let totalNutrientsKCal: TotalNutrientsKCal
}

// MARK: - Ingredient
struct Ingredient: Codable {
    let text: String
    let parsed: [Parsed]?
}

// MARK: - Parsed
struct Parsed: Codable {
    let quantity: Double
    let measure, foodMatch, food, foodId: String
    let weight, retainedWeight: Double
    let nutrients: [String: TotalDaily]
    let measureURI: String
    let status: String}

// MARK: - TotalDaily
struct TotalDaily: Codable {
    let label: String
    let quantity: Double
    let unit: String
}

enum Unit: String, Codable {
    case empty = "%"
    case g = "g"
    case iu = "IU"
    case kcal = "kcal"
    case mg = "mg"
    case µg = "µg"
}

// MARK: - TotalNutrientsKCal
struct TotalNutrientsKCal: Codable {
    let enercKcal, procntKcal, fatKcal, chocdfKcal: TotalDaily
}
