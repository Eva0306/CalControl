//
//  DailyAnalysisCell.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/18.
//

import UIKit
import SwiftUI
import FirebaseCore

class DailyAnalysisCell: BaseCardTableViewCell {
    
    static let identifier = "DailyAnalysisCell"
    
    private var viewModel = DailyAnalysisViewModel()
    private var hostingController: UIHostingController<DailyAnalysisView>?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupHostingController()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupHostingController() {
        let dailyAnalysisView = DailyAnalysisView(viewModel: viewModel, didTappedTargetButton: {[weak self] in
            self?.didTappedTargetButton()
        })
        
        hostingController = UIHostingController(rootView: dailyAnalysisView)
        
        if let hostingController = hostingController {
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            innerContentView.addSubview(hostingController.view)
            
            NSLayoutConstraint.activate([
                hostingController.view.topAnchor.constraint(equalTo: innerContentView.topAnchor),
                hostingController.view.bottomAnchor.constraint(equalTo: innerContentView.bottomAnchor),
                hostingController.view.leadingAnchor.constraint(equalTo: innerContentView.leadingAnchor),
                hostingController.view.trailingAnchor.constraint(equalTo: innerContentView.trailingAnchor)
            ])
        }
    }
    
    func configure(with viewModel: HomeViewModel) {
        self.viewModel.basicGoal = viewModel.userProfileViewModel.userSettings.basicGoal
        self.viewModel.foodValue = Int(viewModel.totalCalories)
        self.viewModel.exerciseValue = viewModel.exerciseValue
        self.viewModel.carbohydrateCurrent = viewModel.totalCarbs
        self.viewModel.carbohydrateTotal = viewModel.userProfileViewModel.userSettings.carbohydrateTotal
        self.viewModel.proteinCurrent = viewModel.totalProtein
        self.viewModel.proteinTotal = viewModel.userProfileViewModel.userSettings.proteinTotal
        self.viewModel.fatCurrent = viewModel.totalFats
        self.viewModel.fatTotal = viewModel.userProfileViewModel.userSettings.fatTotal
    }
    
    private func didTappedTargetButton() {
        print("Target Button Clicked from Cell!")
        let docRef = FirebaseManager.shared.newDocument(of: .foodRecord)
        //        let currentDate = Calendar.current.startOfDay(for: Date())
        var dateComponent = DateComponents()
        dateComponent.year = 2024
        dateComponent.month = 9
        dateComponent.day = 21
        let specificDate = Calendar.current.date(from: dateComponent)
        let currentDate = Calendar.current.startOfDay(for: specificDate!)
        FirebaseManager.shared.setData(
            FoodRecord(title: "Title1", mealType: 3, id: docRef.documentID, userID: "o0rbDjlpam158hluBnaW",
                       date: Timestamp(date: currentDate),
                       nutritionFacts: NutritionFacts(
                        weight: Nutrient(value: 50, unit: "g"),
                        calories: Nutrient(value: 50, unit: "kcal"),
                        carbs: Nutrient(value: 8, unit: "g"),
                        fats: Nutrient(value: 1, unit: "g"),
                        protein: Nutrient(value: 2, unit: "g"))), at: docRef)
        //        let fakeNutrition = TotalNutrition(createdTime: Timestamp(date: currentDate), totalCalories: 0, totalCarbs: 0, totalProtein: 0, totalFats: 0)
        // let nutritionArray = Array(repeating: fakeNutrition, count: 7)
        // let docRef = FirebaseManager.shared.newDocument(of: FirestoreEndpoint.users)
        // FirebaseManager().setData(User(id: docRef.documentID, createdTime: Timestamp(date: Date()),
        //                               name: "楊芮瑊", avatarUrl: nil, gender: 1, birthday: "2000-03-06",
        //                               height: 158, weightRecord: [WeightRecord(createdTime: Timestamp(date: Date()), weight: 50)],
        //                               activity: 1, target: 0, totalNutrition: nutritionArray,
        //                               friends: [Friend(userID: "123123123", addedAt: Timestamp(date: Date()), status: "accepted")]), at: docRef)
    }
}
