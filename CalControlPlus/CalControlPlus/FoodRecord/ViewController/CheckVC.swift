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
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        btn.isSelected = true
        btn.addTarget(self, action: #selector(toggleButtonSelection(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var nutritionButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("營養標示", for: .normal)
        btn.setTitleColor(.lightGray, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        btn.isSelected = false
        btn.addTarget(self, action: #selector(toggleButtonSelection(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var homeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .mainGreen
        let boldConfig = UIImage.SymbolConfiguration(weight: .semibold)
        let homeImage = UIImage(systemName: "house", withConfiguration: boldConfig)
        btn.setImage(homeImage, for: .normal)
        btn.tintColor = .white
        btn.layer.cornerRadius = 8
        btn.addTarget(self, action: #selector(backToHome), for: .touchUpInside)
        return btn
    }()
    
    private lazy var reselectButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .mainGreen
        btn.setTitle("重新選擇", for: .normal)
        btn.tintColor = .white
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        btn.layer.cornerRadius = 8
        btn.addTarget(self, action: #selector(reselectPhoto), for: .touchUpInside)
        return btn
    }()
    
    private lazy var analysisButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .mainGreen
        btn.setTitle("開始分析", for: .normal)
        btn.tintColor = .white
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        btn.layer.cornerRadius = 8
        btn.addTarget(self, action: #selector(analysisPhoto), for: .touchUpInside)
        return btn
    }()
    
    private let loadingView = LoadingView()
    
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
        
        let buttonStackView = UIStackView(arrangedSubviews: [reselectButton, analysisButton])
        buttonStackView.axis = .horizontal
        buttonStackView.alignment = .center
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 20
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(buttonStackView)
        
        let homeStackView = UIStackView(arrangedSubviews: [homeButton, buttonStackView])
        homeStackView.axis = .horizontal
        homeStackView.alignment = .center
        homeStackView.distribution = .fill
        homeStackView.spacing = 20
        homeStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(homeStackView)
        
        let typeButtonStackView = UIStackView(arrangedSubviews: [foodButton, nutritionButton])
        typeButtonStackView.axis = .horizontal
        typeButtonStackView.alignment = .center
        typeButtonStackView.distribution = .fillEqually
        typeButtonStackView.spacing = 20
        typeButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(typeButtonStackView)
        
        NSLayoutConstraint.activate([
            homeButton.heightAnchor.constraint(equalToConstant: 50),
            homeButton.widthAnchor.constraint(equalToConstant: 50),
            reselectButton.heightAnchor.constraint(equalToConstant: 50),
            analysisButton.heightAnchor.constraint(equalToConstant: 50),
            
            homeStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            homeStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            homeStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            homeStackView.heightAnchor.constraint(equalToConstant: 50),
            
            typeButtonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            typeButtonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            typeButtonStackView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -50),
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
        guard let checkPhoto = checkPhoto else { return }
        
        loadingView.show(in: view, withBackground: true)
        
        if classifyType == .food {
            classifyImage(checkPhoto)
        } else if classifyType == .nutritionFact {
            recognizeNutritionFacts(checkPhoto)
        }
    }
}

// MARK: - Classify Image
extension CheckVC {
    
    private func classifyImage(_ image: UIImage) {
        let configuration = MLModelConfiguration()
        
        guard let model = try? FoodImageClassifier(configuration: configuration).model,
              let visionModel = try? VNCoreMLModel(for: model) else {
            debugLog("Failed to load model")
            loadingView.hide()
            showTemporaryAlert(on: self, message: "無法載入模型，請稍後再試", feedbackType: .error)
            return
        }
        
        let request = VNCoreMLRequest(model: visionModel) { [weak self] (request, error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.loadingView.hide()
            }
            
            guard let results = request.results as? [VNClassificationObservation],
                  let firstResult = results.first else {
                debugLog("Couldn't classify the image")
                return
            }
            
            debugLog("\(firstResult.identifier)\nConfidence: \(String(format: "%.2f", firstResult.confidence * 100))%")
            if firstResult.confidence * 100 >= 70 {
                NutritionManager.shared.fetchNutritionFacts(self, mealType: self.mealType ?? 0, ingredient: "one " + firstResult.identifier) { foodRecord in
                    self.goToNutritionVC(image: image, foodRecord: foodRecord)
                }
            } else {
                DispatchQueue.main.async {
                    self.loadingView.hide()
                    showTemporaryAlert(on: self, message: "信心度 < 70%\n換張圖片試試", feedbackType: .error)
                }
            }
        }
        
        guard let ciImage = CIImage(image: image) else {
            DispatchQueue.main.async {
                debugLog("Couldn't transform UIImage to CIImage")
                self.loadingView.hide()
                showTemporaryAlert(on: self, message: "無法處理圖片格式，請更換圖片", feedbackType: .error)
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
                    debugLog("Vision request failed with error - \(error)")
                    self.loadingView.hide()
                    showTemporaryAlert(on: self, message: "分析圖片發生錯誤，請稍後再試", feedbackType: .error)
                }
            }
        }
    }
}

// MARK: - Recognize Nutrition Facts
extension CheckVC {
    
    private func recognizeNutritionFacts(_ image: UIImage) {
        guard let cgImage = image.cgImage else {
            self.loadingView.hide()
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        
        let request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
        
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["zh-Hant", "en"]
        
        do {
            try requestHandler.perform([request])
        } catch {
            debugLog("Unable to perform the requests - \(error)")
            self.loadingView.hide()
        }
    }
    
    private func recognizeTextHandler(request: VNRequest, error: Error?) {
        
        DispatchQueue.main.async {
            self.loadingView.hide()
        }
        
        if let error = error {
            debugLog("Error during text recognition - \(error.localizedDescription)")
            showTemporaryAlert(on: self, message: "無法識別文字，請重試或更換圖片", feedbackType: .error)
            return
        }
        
        guard let observations = request.results as? [VNRecognizedTextObservation], !observations.isEmpty else {
            debugLog("No text recognized.")
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
            
            previousY = currentY
        }
        
        if !currentRow.isEmpty {
            let sortedRow = currentRow.sorted { $0.1.origin.x < $1.1.origin.x }
            nutritionFactsArray.append(sortedRow.map { $0.0 })
        }
        
        if let nutritionFacts = parseNutritionData(from: nutritionFactsArray) {
            let foodRecord = FoodRecord(
                mealType: mealType ?? 0,
                id: "",
                userID: UserProfileViewModel.shared.user.id,
                nutritionFacts: nutritionFacts, imageUrl: nil
            )
            goToNutritionVC(image: checkPhoto, foodRecord: foodRecord)
        }
    }
    
    private func showNoTextAlert() {
        HapticFeedbackHelper.generateNotificationFeedback(type: .error)
        let alert = UIAlertController(
            title: "找不到文字",
            message: "請試試其他照片，或使用文字輸入",
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
                let unit = array[0].contains("公克") ? "公克" : "毫升"
                if let weightValue = Double(array[0].components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
                    weight = Nutrient(value: weightValue, unit: unit)
                }
            }
            
            if array[0].contains("本包裝含") {
                if let servingsValue = Double(array[0].components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
                    servings = servingsValue
                }
            }
        }
        
        return (weight, servings)
    }
    
    private func parseNutritionalValues(from nutritionFactsArray: [[String]]) -> [String: Nutrient] {
        var nutritionValues: [String: Nutrient] = [:]
        
        for array in nutritionFactsArray {
            guard array.count > 1 else { continue }
            let value = Double(array[1].components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted).joined()) ?? 0
            switch array[0] {
            case "熱量":
                nutritionValues["calories"] = Nutrient(value: value, unit: "大卡")
            case "蛋白質":
                nutritionValues["protein"] = Nutrient(value: value, unit: "公克")
            case "碳水化合物":
                nutritionValues["carbs"] = Nutrient(value: value, unit: "公克")
            case "脂肪":
                nutritionValues["fats"] = Nutrient(value: value, unit: "公克")
            default:
                break
            }
        }
        return nutritionValues
    }
}

// MARK: - Go To Nutrition VC
extension CheckVC {
    func goToNutritionVC(image: UIImage?, foodRecord: FoodRecord?) {
        loadingView.hide()
        let nutritionVC = NutritionVC()
        nutritionVC.isFromText = false
        nutritionVC.checkPhoto = image
        nutritionVC.foodRecord = foodRecord
        nutritionVC.modalPresentationStyle = .fullScreen
        self.present(nutritionVC, animated: true, completion: nil)
    }
}
