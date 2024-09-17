//
//  CheckVC.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/11.
//

import UIKit
import CoreML
import Vision

class CheckVC: UIViewController {
    
    var checkPhoto: UIImage?
    
    var mealType: Int?
    
    private let checkImageView = UIImageView()
    
    private var classifyType: ClassifyType = .food
    
    private var nutritionFactsArray: [[String]] = []
    
    private lazy var foodButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("食物", for: .normal)
        btn.setTitleColor(.mainGreen, for: .normal)
        btn.isSelected = true
        btn.addTarget(self, action: #selector(toggleButtonSelection(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var nutritionButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("營養標示", for: .normal)
        btn.setTitleColor(.lightGray, for: .normal)
        btn.isSelected = false
        btn.addTarget(self, action: #selector(toggleButtonSelection(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var homeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Home", for: .normal)
        btn.addTarget(self, action: #selector(backToHome), for: .touchUpInside)
        return btn
    }()
    
    private lazy var reselectButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Reselect", for: .normal)
        btn.addTarget(self, action: #selector(reselectPhoto), for: .touchUpInside)
        return btn
    }()
    
    private lazy var analysisButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Analysis", for: .normal)
        btn.addTarget(self, action: #selector(analysisPhoto), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        setupView()
        setupButtons()
    }
    
    private func setupView() {
        
        checkImageView.contentMode = .scaleAspectFit
        checkImageView.clipsToBounds = true
        checkImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(checkImageView)
        
        NSLayoutConstraint.activate([
            checkImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            checkImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 120),
            checkImageView.widthAnchor.constraint(equalToConstant: 300),
            checkImageView.heightAnchor.constraint(equalToConstant: 500)
        ])
        
        if let photo = checkPhoto {
            checkImageView.image = photo
        }
    }
    
    private func setupButtons() {
        
        let buttonStackView = UIStackView(arrangedSubviews: [homeButton, reselectButton, analysisButton])
        buttonStackView.axis = .horizontal
        buttonStackView.alignment = .center
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 20
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(buttonStackView)
        
        let typeButtonStackView = UIStackView(arrangedSubviews: [foodButton, nutritionButton])
        typeButtonStackView.axis = .horizontal
        typeButtonStackView.alignment = .center
        typeButtonStackView.distribution = .fillEqually
        typeButtonStackView.spacing = 20
        typeButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(typeButtonStackView)
        
        NSLayoutConstraint.activate([
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            buttonStackView.heightAnchor.constraint(equalToConstant: 50),
            typeButtonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            typeButtonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            typeButtonStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -130),
            typeButtonStackView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func toggleButtonSelection(_ sender: UIButton) {
        
        if sender == foodButton {
            classifyType = .food
            
            foodButton.isSelected = true
            nutritionButton.isSelected = false
            
            foodButton.setTitleColor(.mainGreen, for: .normal)
            nutritionButton.setTitleColor(.lightGray, for: .normal)
            
        } else if sender == nutritionButton {
            classifyType = .nutritionFact
            
            nutritionButton.isSelected = true
            foodButton.isSelected = false
            
            nutritionButton.setTitleColor(.mainGreen, for: .normal)
            foodButton.setTitleColor(.lightGray, for: .normal)
        }
    }
    
    @objc private func backToHome() {
        
        presentingViewController?.presentingViewController?.dismiss(animated: true, completion: {
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let mainTabBarController = window.rootViewController as? UITabBarController {
                mainTabBarController.selectedIndex = 0
            }
        })
    }
    
    @objc private func reselectPhoto() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func analysisPhoto() {
        if let checkPhoto = checkPhoto {
            
            if classifyType == .food {
                classifyImage(checkPhoto)
                
            } else if classifyType == .nutritionFact {
                recognizeNutritionFacts(checkPhoto)
            }
        }
    }
}

// MARK: - Classify Image
extension CheckVC {
    
    func classifyImage(_ image: UIImage) {
        
        let configuration = MLModelConfiguration()
        
        guard let model = try? FoodImageClassifier(configuration: configuration).model,
              let visionModel = try? VNCoreMLModel(for: model) else {
            print("Failed to load model")
            return
        }
        
        
        
        let request = VNCoreMLRequest(model: visionModel) { (request, error) in
            
            guard let results = request.results as? [VNClassificationObservation], let firstResult = results.first else {
                print("Couldn't classify the image")
                return
            }
            
            print("\(firstResult.identifier)\nConfidence: \(String(format: "%.2f", firstResult.confidence * 100))%")
            if firstResult.confidence * 100 >= 70 {
                
                NutritionManager.shared.fetchNutritionFacts(self, mealType: self.mealType ?? 0, ingredient: "one " + firstResult.identifier) { nutritionFacts in
                    
                    if let nutritionFacts = nutritionFacts {
                        DispatchQueue.main.async {
                            self.goToNutritionVC(image: image, nutritionFacts: nutritionFacts)
                        }
                    } else {
                        print("Failed to fetch nutrition facts.")
                    }
                }
            }
        }
        
        guard let ciImage = CIImage(image: image) else {
            DispatchQueue.main.async {
                print("Couldn't transform UIImage to CIImage")
            }
            return
        }
        
        #if targetEnvironment(simulator)
        request.usesCPUOnly = true
        #endif
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    print("Vision request failed with error: \(error)")
                }
            }
        }
    }
}

// MARK: - Recognize Nutrition Facts
extension CheckVC {
    
    func recognizeNutritionFacts(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage)

        let request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
        
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["zh-Hant", "en"]

        do {
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the requests: \(error).")
        }
    }
    
    func recognizeTextHandler(request: VNRequest, error: Error?) {
        
        if let error = error {
            print("Error during text recognition: \(error.localizedDescription)")
            return
        }
        
        guard let observations = request.results as? [VNRecognizedTextObservation], !observations.isEmpty else {
            print("No text recognized.")
            showNoTextAlert()
            return
        }

        // 儲存每一行的文字和其 boundingBox 的資料
        var lineData: [(String, CGRect)] = []

        // 將每個觀察到的文字與 boundingBox 一起儲存
        for observation in observations {
            if let topCandidate = observation.topCandidates(1).first {
                lineData.append((topCandidate.string, observation.boundingBox))
            }
        }

        // 依照 boundingBox 的 y 座標進行排序，確保從上到下處理每行
        lineData.sort { $0.1.origin.y > $1.1.origin.y }

        // 根據 y 座標的相似性來分組（每一行的文字）
        var currentRow: [(String, CGRect)] = []
        var previousY: CGFloat = -1.0

        for (text, boundingBox) in lineData {
            // 當前文字的 y 座標
            let currentY = boundingBox.origin.y

            // 如果是同一行 (y 座標接近)，就加入到當前行
            if previousY == -1.0 || abs(previousY - currentY) < 0.03 {
                currentRow.append((text, boundingBox))
            } else {
                // 如果不是同一行，則將當前行按 x 座標從左到右排序後加入 tableRows
                if !currentRow.isEmpty {
                    let sortedRow = currentRow.sorted { $0.1.origin.x < $1.1.origin.x }
                    nutritionFactsArray.append(sortedRow.map { $0.0 })
                }
                currentRow = [(text, boundingBox)]
            }
            
            // 更新上一個 y 座標
            previousY = currentY
        }
        
        // 處理最後一行
        if !currentRow.isEmpty {
            let sortedRow = currentRow.sorted { $0.1.origin.x < $1.1.origin.x }
            nutritionFactsArray.append(sortedRow.map { $0.0 })
        }
        print(nutritionFactsArray)
        print("Recognize Text ======================")
        if let nutritionFacts = parseNutritionData(from: nutritionFactsArray) {
            goToNutritionVC(image: checkPhoto, nutritionFacts: nutritionFacts)
            print(nutritionFacts, "\n==============")
        }
    }
    
    func showNoTextAlert() {
        let alert = UIAlertController(
            title: "No Text Found",
            message: "The image does not contain recognizable text. Please try again with a different image.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Parse Nutrition Data
extension CheckVC {
    func parseNutritionData(from nutritionFactsArray: [[String]]) -> NutritionFacts? {
        var weight = Nutrient(value: 0, unit: "毫升")
        var servings: Double = 1
        
        var calories = Nutrient(value: 0, unit: "大卡")
        var carbs = Nutrient(value: 0, unit: "公克")
        var fats = Nutrient(value: 0, unit: "公克")
        var protein = Nutrient(value: 0, unit: "公克")
        
        // 提取重量和份量
        for array in nutritionFactsArray {
            if array[0].contains("每一份量") {
                // 提取份量的重量，假設格式為 "每一份量400毫升"
                let unit = array[0].contains("公克") ? "公克" : "毫升"
                if let weightValue = Double(array[0].components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
                    weight = Nutrient(value: weightValue, unit: unit)
                }
            }
            
            if array[0].contains("本包裝含") {
                // 提取包裝份量，假設格式為 "本包裝含1份"
                if let servingsValue = Double(array[0].components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
                    servings = servingsValue
                }
            }
        }
        
        // 解析營養數據
        for array in nutritionFactsArray {
            if array[0] == "熱量" {
                let caloriesValue = Double(array[1].components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted).joined()) ?? 0
                calories = Nutrient(value: caloriesValue, unit: "大卡")
            } else if array[0] == "蛋白質" {
                let proteinValue = Double(array[1].components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted).joined()) ?? 0
                protein = Nutrient(value: proteinValue, unit: "公克")
            } else if array[0] == "碳水化合物" {
                let carbsValue = Double(array[1].components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted).joined()) ?? 0
                carbs = Nutrient(value: carbsValue, unit: "公克")
            } else if array[0] == "脂肪" {
                let fatsValue = Double(array[1].components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted).joined()) ?? 0
                fats = Nutrient(value: fatsValue, unit: "公克")
            }
        }
        
        // 使用乘積來計算最終值
        let finalWeight = Nutrient(value: weight.value * servings, unit: weight.unit)
        let finalCalories = Nutrient(value: calories.value * servings, unit: calories.unit)
        let finalCarbs = Nutrient(value: carbs.value * servings, unit: carbs.unit)
        let finalFats = Nutrient(value: fats.value * servings, unit: fats.unit)
        let finalProtein = Nutrient(value: protein.value * servings, unit: protein.unit)
        
        return NutritionFacts(title: nil, mealType: mealType ?? 0, weight: finalWeight,
                              calories: finalCalories, carbs: finalCarbs, fats: finalFats, protein: finalProtein)
    }
}

// MARK: - Go To Nutrition VC
extension CheckVC {
    func goToNutritionVC(image: UIImage?, nutritionFacts: NutritionFacts?) {
        let nutritionVC = NutritionVC()
        nutritionVC.isFromText = false
        nutritionVC.checkPhoto = image
        nutritionVC.nutritionFacts = nutritionFacts
        nutritionVC.modalPresentationStyle = .fullScreen
        self.present(nutritionVC, animated: true, completion: nil)
    }
}
