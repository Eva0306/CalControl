//
//  InfoStartVC.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/28.
//

import UIKit
import FirebaseFirestore

class InfoStartVC: UIViewController {
    
    private lazy var confirmButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Confirm", for: .normal)
        btn.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 8
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.lightGreen.cgColor
        btn.backgroundColor = .lightGreen
        btn.tintColor = .white
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(confirmButton)
        
        NSLayoutConstraint.activate([
            confirmButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            confirmButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            confirmButton.heightAnchor.constraint(equalToConstant: 50),
            confirmButton.widthAnchor.constraint(equalToConstant: 200)
        ])
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
            // 沒有圖片時直接上傳資料
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
