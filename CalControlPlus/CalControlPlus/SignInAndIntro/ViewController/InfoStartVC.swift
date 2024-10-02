//
//  InfoStartVC.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/28.
//

import UIKit
import FirebaseFirestore
import Lottie

class InfoStartVC: UIViewController {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "開始你的健康之旅吧"
        label.textAlignment = .center
        label.textColor = .darkGreen
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var confirmButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Confirm", for: .normal)
        btn.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 8
        btn.backgroundColor = .clear
        btn.tintColor = .white
        return btn
    }()
    
    private var ribbonAnimationView: LottieAnimationView?
    private var buttonAnimationView: LottieAnimationView?
    private var foodAnimationView: LottieAnimationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        setupUI()
        setupLottieAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupRibbonAnimation()
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(confirmButton)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            
            confirmButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            confirmButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 100),
            confirmButton.heightAnchor.constraint(equalToConstant: 50),
            confirmButton.widthAnchor.constraint(equalToConstant: 250)
        ])
    }
    
    private func setupRibbonAnimation() {
        ribbonAnimationView = LottieAnimationView(name: "RibbonAnimation")
        guard let ribbonAnimationView = ribbonAnimationView else { return }
        
        ribbonAnimationView.translatesAutoresizingMaskIntoConstraints = false
        ribbonAnimationView.contentMode = .scaleAspectFill
        ribbonAnimationView.loopMode = .playOnce
        ribbonAnimationView.isUserInteractionEnabled = false
        
        view.addSubview(ribbonAnimationView)
        
        NSLayoutConstraint.activate([
            ribbonAnimationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ribbonAnimationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ribbonAnimationView.topAnchor.constraint(equalTo: view.topAnchor),
            ribbonAnimationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        ribbonAnimationView.play()
    }
    
    private func setupLottieAnimation() {
        buttonAnimationView = LottieAnimationView(name: "ButtonAnimation")
        foodAnimationView = LottieAnimationView(name: " FoodCarouselAnimation")
        guard let buttonAnimationView = buttonAnimationView,
              let foodAnimationView = foodAnimationView else { return }
        
        buttonAnimationView.translatesAutoresizingMaskIntoConstraints = false
        buttonAnimationView.contentMode = .scaleAspectFill
        buttonAnimationView.loopMode = .loop
        buttonAnimationView.isUserInteractionEnabled = false
        
        foodAnimationView.translatesAutoresizingMaskIntoConstraints = false
        foodAnimationView.contentMode = .scaleAspectFit
        foodAnimationView.loopMode = .loop
        foodAnimationView.isUserInteractionEnabled = false
        
        view.addSubview(foodAnimationView)
        
        confirmButton.addSubview(buttonAnimationView)
        confirmButton.sendSubviewToBack(buttonAnimationView)
        
        NSLayoutConstraint.activate([
            foodAnimationView.widthAnchor.constraint(equalToConstant: 150),
            foodAnimationView.heightAnchor.constraint(equalToConstant: 150),
            foodAnimationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            foodAnimationView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            
            buttonAnimationView.leadingAnchor.constraint(equalTo: confirmButton.leadingAnchor),
            buttonAnimationView.trailingAnchor.constraint(equalTo: confirmButton.trailingAnchor),
            buttonAnimationView.topAnchor.constraint(equalTo: confirmButton.topAnchor),
            buttonAnimationView.bottomAnchor.constraint(equalTo: confirmButton.bottomAnchor)
        ])
        
        foodAnimationView.play()
        buttonAnimationView.play()
    }
    
    @objc private func confirmButtonTapped() {
        let viewModel = UserInfoCollector.shared
        
        guard let userID = viewModel.userID,
              let name = viewModel.name,
              let gender = viewModel.gender,
              let birthday = viewModel.birthday,
              let height = viewModel.height,
              let weight = viewModel.weight,
              let activity = viewModel.activity,
              let target = viewModel.target else {
            print("Please fill in all required fields.")
            return
        }
        
        if let avatarImage = viewModel.avatarImage {
            FirebaseManager.shared.uploadImage(image: avatarImage) { url in
                self.saveUserData(
                    userID: userID,
                    name: name,
                    email: viewModel.email,
                    avatarUrl: url?.absoluteString,
                    gender: gender,
                    birthday: birthday,
                    height: height,
                    weight: weight,
                    activity: activity,
                    target: target
                )
            }
        } else {
            saveUserData(
                userID: userID,
                name: name,
                email: viewModel.email,
                avatarUrl: nil,
                gender: gender,
                birthday: birthday,
                height: height,
                weight: weight,
                activity: activity,
                target: target
            )
        }
    }
    // swiftlint:disable function_parameter_count line_length
    private func saveUserData(userID: String, name: String, email: String?, avatarUrl: String?, gender: Gender, birthday: String, height: Double, weight: Double, activity: ActivityLevel, target: Target) {
        // swiftlint:enable function_parameter_count line_length
        let userData: User = User(
            id: userID,
            createdTime: Timestamp(date: Date()),
            email: email,
            name: name,
            avatarUrl: avatarUrl,
            gender: gender,
            birthday: birthday,
            height: height,
            weightRecord: [WeightRecord(date: Timestamp(date: Date()), weight: weight)],
            activity: activity,
            target: target,
            totalNutrition: self.generateBlankNutriData()
        )
        
        let userRef = FirebaseManager.shared.newDocument(of: .users, documentID: userID)
        FirebaseManager.shared.setData(userData, at: userRef, merge: false)
        
        UserProfileViewModel.shared = UserProfileViewModel(user: userData)
        
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            // swiftlint:disable force_cast
            let tabBarController = storyboard.instantiateInitialViewController() as! MainTabBarController
            // swiftlint:enable force_cast
            window.rootViewController = tabBarController
            window.makeKeyAndVisible()
        }
    }
    
    private func generateBlankNutriData() -> [TotalNutrition] {
        let currentDate = Calendar.current.startOfDay(for: Date())
        var nutritionArray: [TotalNutrition] = []
        for i in 0..<7 {
            if let previousDate = Calendar.current.date(byAdding: .day, value: -i, to: currentDate) {
                let nutrition = TotalNutrition(
                    date: Timestamp(date: previousDate),
                    totalCalories: 0,
                    totalCarbs: 0,
                    totalProtein: 0,
                    totalFats: 0
                )
                nutritionArray.insert(nutrition, at: 0)
            }
        }
        return nutritionArray
    }
}
