//
//  HttpManager.swift
//  FoodClassifier
//
//  Created by 楊芮瑊 on 2024/9/9.
//

import Foundation

class HttpManager {
    
    func fetchNutrition(ingredient: String, completion: @escaping (Result<NutritionResponse, Error>) -> Void) {
        
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
                        print("Decoding error: \(error)")
                    }
                }
            }
        }
        
        task.resume()
    }
}
