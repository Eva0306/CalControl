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
    
    private var classifyType: ClassifyType = .food
    
    private var nutritionFactsArray: [[String]] = []
    
    private lazy var navigationBar: UINavigationBar = {
        let navBar = UINavigationBar()
        navBar.isTranslucent = true
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.backgroundColor = .clear
        navBar.translatesAutoresizingMaskIntoConstraints = false
        return navBar
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.text = "確認照片"
        label.numberOfLines = 0
        label.textColor = .darkGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.text = "使用背景愈乾淨，辨識精準度愈高！"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return .lightGray
            default:
                return .darkGray
            }
        }
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    private lazy var saveImageButton: UIBarButtonItem = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "square.and.arrow.down"), for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.contentHorizontalAlignment = .fill
        btn.contentVerticalAlignment = .fill
        btn.tintColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return .white
            default:
                return .darkGray
            }
        }
        btn.addTarget(self, action: #selector(saveImage), for: .touchUpInside)
        return UIBarButtonItem(customView: btn)
    }()
    
    private lazy var checkImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
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
        setupNavigationBar()
        setupButtonsAndImageView()
    }
    
    private func setupNavigationBar() {
        let navItem = UINavigationItem()
        navItem.rightBarButtonItem = saveImageButton
        navItem.titleView = titleLabel
        
        navigationBar.setItems([navItem], animated: false)
        
        view.addSubview(navigationBar)
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupButtonsAndImageView() {
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
        view.addSubview(checkImageView)
        
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
            typeButtonStackView.heightAnchor.constraint(equalToConstant: 50),
            
            checkImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            checkImageView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
            checkImageView.bottomAnchor.constraint(equalTo: typeButtonStackView.topAnchor, constant: -20),
            checkImageView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            checkImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        if let photo = checkPhoto {
            checkImageView.image = photo.withRoundedCorners(radius: 18)
        }
    }
    
    @objc private func saveImage() {
        guard let image = checkPhoto else {
            debugLog("Failed to load image")
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            debugLog("Error saving image: \(error.localizedDescription)")
            showTemporaryAlert(on: self, message: "儲存圖片失敗")
        } else {
            debugLog("Image saved successfully")
            showTemporaryAlert(on: self, message: "圖片已儲存到相簿")
        }
    }
    
    @objc private func toggleButtonSelection(_ sender: UIButton) {
        
        if sender == foodButton {
            classifyType = .food
            descriptionLabel.text = "使用背景愈乾淨，辨識精準度愈高！"
            
            foodButton.isSelected = true
            nutritionButton.isSelected = false
            
            foodButton.setTitleColor(.mainGreen, for: .normal)
            nutritionButton.setTitleColor(.lightGray, for: .normal)
            
        } else if sender == nutritionButton {
            classifyType = .nutritionFact
            descriptionLabel.text = "裁切相片範圍至營養標示框會更精準！"
            
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
        ImageClassifier().classify(image: image) { [weak self] identifier, confidence in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.loadingView.hide()
            }
            
            guard let identifier = identifier, let confidence = confidence else {
                debugLog("Couldn't classify the image")
                return
            }
            
            debugLog("\(identifier)\nConfidence: \(String(format: "%.2f", confidence))%")
            if confidence >= 70 {
                NutritionManager.shared.fetchNutritionFacts(
                    self,
                    mealType: self.mealType ?? 0, ingredient: "one " + identifier
                ) { foodRecord in
                    self.goToNutritionVC(image: image, foodRecord: foodRecord)
                }
            } else {
                DispatchQueue.main.async {
                    self.loadingView.hide()
                    showTemporaryAlert(on: self, message: "信心度 < 70%\n換張圖片試試", feedbackType: .error)
                }
            }
        }
    }
}

// MARK: - Recognize Nutrition Facts
extension CheckVC {
    private func recognizeNutritionFacts(_ image: UIImage) {
        NutritionFactsParser().recognizeNutritionFacts(from: image) { [weak self] nutritionFactsArray in
            guard let self = self else { return }
            
            guard let nutritionFacts = NutritionFactsParser().parseNutritionData(from: nutritionFactsArray) else {
                self.showNoTextAlert()
                return
            }
            
            let foodRecord = FoodRecord(
                mealType: mealType ?? 0,
                id: "",
                userID: UserProfileViewModel.shared.user.id,
                nutritionFacts: nutritionFacts, imageUrl: nil
            )
            self.goToNutritionVC(image: self.checkPhoto, foodRecord: foodRecord)
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
