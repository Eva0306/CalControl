//
//  NutritionCalculatorTests.swift
//  CalControlPlusTests
//
//  Created by 楊芮瑊 on 2024/10/17.
//

import XCTest
import FirebaseCore
@testable import CalControlPlus

final class NutritionCalculatorTests: XCTestCase {

    var sampleRecords: [FoodRecord]!
    var date: Date!

    override func setUpWithError() throws {
        date = Date()
        
        let record1 = FoodRecord(
            title: "Apple",
            mealType: 1,
            id: "1",
            userID: "user123",
            date: Timestamp(date: date),
            nutritionFacts: NutritionFacts(
                weight: Nutrient(value: 150, unit: "g"),
                calories: Nutrient(value: 52, unit: "kcal"),
                carbs: Nutrient(value: 14, unit: "g"),
                fats: Nutrient(value: 0.2, unit: "g"),
                protein: Nutrient(value: 0.3, unit: "g")
            ),
            imageUrl: nil
        )
        
        let record2 = FoodRecord(
            title: "Banana",
            mealType: 1,
            id: "2",
            userID: "user123",
            date: Timestamp(date: date),
            nutritionFacts: NutritionFacts(
                weight: Nutrient(value: 118, unit: "g"),
                calories: Nutrient(value: 89, unit: "kcal"),
                carbs: Nutrient(value: 23, unit: "g"),
                fats: Nutrient(value: 0.3, unit: "g"),
                protein: Nutrient(value: 1.1, unit: "g")
            ),
            imageUrl: nil
        )
        
        sampleRecords = [record1, record2]
    }

    override func tearDownWithError() throws {
        sampleRecords = nil
        date = nil
    }

    func testCalculateTotalNutrition() throws {
        let result = NutritionCalculator.calculateTotalNutrition(from: sampleRecords, for: date)
        
        XCTAssertEqual(result.totalCalories, 141.0) // 52 + 89
        XCTAssertEqual(result.totalCarbs, 37.0)     // 14 + 23
        XCTAssertEqual(result.totalFats, 0.5)       // 0.2 + 0.3
        XCTAssertEqual(result.totalProtein, 1.4)    // 0.3 + 1.1
    }
    
    func testPerformanceCalculateTotalNutrition() throws {
        self.measure {
            _ = NutritionCalculator.calculateTotalNutrition(from: sampleRecords, for: date)
        }
    }
    
    func testCalculateWeeklyBudget() throws {
        let basicGoal = 2000
        
        let totalNutrition1 = TotalNutrition(
            date: Timestamp(date: Date()),
            totalCalories: 1800.0,
            totalCarbs: 250.0,
            totalProtein: 80.0,
            totalFats: 50.0
        )
        
        let totalNutrition2 = TotalNutrition(
            date: Timestamp(date: Date().addingTimeInterval(-86400)),
            totalCalories: 1900.0,
            totalCarbs: 260.0,
            totalProtein: 85.0,
            totalFats: 55.0
        )

        let weeklyRecords = [totalNutrition1, totalNutrition2]

        let result = NutritionCalculator.calculateWeeklyBudget(from: weeklyRecords, basicGoal: basicGoal)

        let expectedWeeklyCal = (basicGoal * 7) - (1800 + 1900)
        XCTAssertEqual(result, expectedWeeklyCal)
    }
}
