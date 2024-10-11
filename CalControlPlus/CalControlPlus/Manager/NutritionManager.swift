//
//  NutritionManager.swift
//  FoodClassifier
//
//  Created by 楊芮瑊 on 2024/9/9.
//

import Foundation
import UIKit

class NutritionManager: NSObject {
    
    static let shared = NutritionManager()
    
    override init() {
        super.init()
    }
    
    private func fetchNutrition(ingredient: String, completion: @escaping (Result<NutritionResponse, Error>) -> Void) {
        
        let appId = "f1e74560"
        
        let appKey = "69e1a9ce44414a206e36e8286b680ad7"
        
        let urlString =  "https://api.edamam.com/api/nutrition-data?app_id=\(appId)&app_key=\(appKey)&ingr=\(ingredient)"
        
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            if let data = data {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                do {
                    let nutritionData = try decoder.decode(NutritionResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(nutritionData))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                        debugLog("Decoding error - \(error)")
                    }
                }
            }
        }
        
        task.resume()
    }
    
    func fetchNutritionFacts(_ viewController: UIViewController, mealType: Int, ingredient: String, completion: @escaping (FoodRecord?) -> Void) {
        fetchNutrition(ingredient: ingredient) { result in
            switch result {
            case .success(let nutritionData):
                guard let calcoriesData = nutritionData.totalNutrients["ENERC_KCAL"],
                      let proteinData = nutritionData.totalNutrients["PROCNT"],
                      let carbsData = nutritionData.totalNutrients["CHOCDF"],
                      let fatsData = nutritionData.totalNutrients["FAT"] else {
                    debugLog("Lose data")
                    self.showAlert(on: viewController)
                    completion(nil)
                    return
                }

                let nutritionFacts = NutritionFacts(
                    weight: Nutrient(value: nutritionData.totalWeight.rounded(toPlaces: 2), unit: "g"),
                    calories: Nutrient(value: calcoriesData.quantity.rounded(toPlaces: 2), unit: calcoriesData.unit),
                    carbs: Nutrient(value: carbsData.quantity.rounded(toPlaces: 2), unit: carbsData.unit),
                    fats: Nutrient(value: fatsData.quantity.rounded(toPlaces: 2), unit: fatsData.unit),
                    protein: Nutrient(value: proteinData.quantity.rounded(toPlaces: 2), unit: proteinData.unit)
                )
                
                let foodRecord = FoodRecord(
                    title: nutritionData.ingredients?.first?.parsed?.first?.foodMatch,
                    mealType: mealType,
                    id: "",
                    userID: UserProfileViewModel.shared.user.id,
                    date: nil,
                    nutritionFacts: nutritionFacts,
                    imageUrl: nil
                )
                
                completion(foodRecord)
                
            case .failure(let error):
                debugLog("Failed to fetch product data - \(error)")
                completion(nil)
            }
        }
    }

    func showAlert(on viewController: UIViewController) {
        HapticFeedbackHelper.generateNotificationFeedback(type: .error)
        let alert = UIAlertController(
            title: "獲取營養素失敗",
            message: "嘗試使用其他照片或文字輸入",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        viewController.present(alert, animated: true, completion: nil)
    }
}
