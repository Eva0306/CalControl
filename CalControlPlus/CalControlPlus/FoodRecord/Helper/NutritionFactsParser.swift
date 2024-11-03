//
//  NutritionFactsParser.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/10/14.
//

import UIKit
import Vision

class NutritionFactsParser {
    func recognizeNutritionFacts(from image: UIImage, completion: @escaping ([[String]]) -> Void) {
        guard let cgImage = image.cgImage else {
            completion([])
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        let request = VNRecognizeTextRequest { [weak self] request, error in
            if let error = error {
                print("Error during text recognition: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation], !observations.isEmpty else {
                print("No text recognized.")
                completion([])
                return
            }
            
            let lineData = self?.extractLineData(from: observations) ?? []
            let nutritionFactsArray = self?.processLineData(lineData) ?? []
            completion(nutritionFactsArray)
        }
        
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["zh-Hant", "en"]
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the request: \(error)")
            completion([])
        }
    }

    private func extractLineData(from observations: [VNRecognizedTextObservation]) -> [(String, CGRect)] {
        var lineData: [(String, CGRect)] = []
        for observation in observations {
            if let topCandidate = observation.topCandidates(1).first {
                lineData.append((topCandidate.string, observation.boundingBox))
            }
        }
        return lineData
    }

    private func processLineData(_ lineData: [(String, CGRect)]) -> [[String]] {
        let sortedLineData = lineData.sorted { $0.1.origin.y > $1.1.origin.y }
        
        var nutritionFactsArray: [[String]] = []
        var currentRow: [(String, CGRect)] = []
        var previousY: CGFloat = -1.0
        
        for (text, boundingBox) in sortedLineData {
            let currentY = boundingBox.origin.y
            
            if previousY == -1.0 || abs(previousY - currentY) < 0.03 {
                currentRow.append((text, boundingBox))
            } else {
                if !currentRow.isEmpty {
                    let sortedRow = currentRow.sorted { $0.1.origin.x < $1.1.origin.x }
                    nutritionFactsArray.append(sortedRow.map { $0.0 })
                }
                currentRow = [(text, boundingBox)]
            }
            previousY = currentY
        }
        
        if !currentRow.isEmpty {
            let sortedRow = currentRow.sorted { $0.1.origin.x < $1.1.origin.x }
            nutritionFactsArray.append(sortedRow.map { $0.0 })
        }
        
        return nutritionFactsArray
    }
    
    // MARK: - Nutrition Data Parsing
    func parseNutritionData(from nutritionFactsArray: [[String]]) -> NutritionFacts? {
        let (weight, servings) = parseWeightAndServings(from: nutritionFactsArray)
        let nutritionValues = parseNutritionalValues(from: nutritionFactsArray)
        
        let finalWeight = Nutrient(value: weight.value * servings, unit: weight.unit)
        let finalCalories = Nutrient(
            value: (nutritionValues["calories"]?.value ?? 0) * servings,
            unit: nutritionValues["calories"]?.unit ?? "大卡"
        )
        let finalCarbs = Nutrient(
            value: (nutritionValues["carbs"]?.value ?? 0) * servings,
            unit: nutritionValues["carbs"]?.unit ?? "公克"
        )
        let finalFats = Nutrient(
            value: (nutritionValues["fats"]?.value ?? 0) * servings,
            unit: nutritionValues["fats"]?.unit ?? "公克"
        )
        let finalProtein = Nutrient(
            value: (nutritionValues["protein"]?.value ?? 0) * servings,
            unit: nutritionValues["protein"]?.unit ?? "公克"
        )
        
        return NutritionFacts(weight: finalWeight, calories: finalCalories,
                              carbs: finalCarbs, fats: finalFats, protein: finalProtein)
    }
    
    private func parseWeightAndServings(from nutritionFactsArray: [[String]]) -> (weight: Nutrient, servings: Double) {
        var weight = Nutrient(value: 0, unit: "毫升")
        var servings: Double = 1
        
        for array in nutritionFactsArray {
            guard !array.isEmpty else { continue }
            
            if array[0].contains("每一份量") {
                let unit: String
                if array[0].contains("公克") {
                    unit = "公克"
                } else if array.count > 1 && array[1].contains("公克") {
                    unit = "公克"
                } else {
                    unit = "毫升"
                }
                let weightValue = extractNumericValue(from: array)
                weight = Nutrient(value: weightValue, unit: unit)
            }
            if array[0].contains("本包裝含") {
                let servingsValue = extractNumericValue(from: array)
                servings = servingsValue
            }
        }
        return (weight, servings)
    }
    
    private func extractNumericValue(from array: [String]) -> Double {
        for item in array {
            if let value = Double(item.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
                return value
            }
        }
        return 0
    }
    
    private func parseNutritionalValues(from nutritionFactsArray: [[String]]) -> [String: Nutrient] {
        var nutritionValues: [String: Nutrient] = [:]
        
        for array in nutritionFactsArray {
            guard array.count > 0 else { continue }
            
            let (nutrientName, valueParts) = splitTextAndValue(from: array[0])
            
            guard !nutrientName.isEmpty else { continue }
            
            var allValues = valueParts
            
            if array.count > 1 {
                let additionalValues = splitMultipleValues(from: array[1])
                allValues.append(contentsOf: additionalValues)
            }
            
            if let firstValuePart = allValues.first {
                let numericValue = Double(
                    firstValuePart
                        .components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted)
                        .joined()
                ) ?? 0
                let unit = firstValuePart.components(separatedBy: CharacterSet.decimalDigits).last ?? ""
                
                switch nutrientName {
                case "熱量":
                    nutritionValues["calories"] = Nutrient(value: numericValue, unit: unit)
                case "蛋白質":
                    nutritionValues["protein"] = Nutrient(value: numericValue, unit: unit)
                case "碳水化合物":
                    nutritionValues["carbs"] = Nutrient(value: numericValue, unit: unit)
                case "脂肪":
                    nutritionValues["fats"] = Nutrient(value: numericValue, unit: unit)
                default:
                    break
                }
            }
        }
        
        return nutritionValues
    }
    
    private func splitTextAndValue(from text: String) -> (String, [String]) {
        let pattern = "([\\u4e00-\\u9fa5]+)([0-9\\.]+[\\u4e00-\\u9fa5]+)"
        
        var textPart: String = ""
        var valueParts: [String] = []
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
            
            let nsText = text as NSString
            
            for match in matches {
                let textRange = match.range(at: 1)
                let valueRange = match.range(at: 2)
                
                if textRange.length > 0 {
                    textPart = nsText.substring(with: textRange)
                }
                
                if valueRange.length > 0 {
                    valueParts.append(nsText.substring(with: valueRange))
                }
            }
        }
        
        return (textPart.isEmpty ? text : textPart, valueParts)
    }

    private func splitMultipleValues(from text: String) -> [String] {
        let pattern = "[0-9\\.]+[\\u4e00-\\u9fa5]+"
        
        var results: [String] = []
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
            
            let nsText = text as NSString
            
            for match in matches {
                let value = nsText.substring(with: match.range)
                results.append(value)
            }
        }
        
        return results.isEmpty ? [text] : results
    }
}
