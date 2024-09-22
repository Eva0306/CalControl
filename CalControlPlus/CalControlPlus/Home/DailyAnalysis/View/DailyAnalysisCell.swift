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
    
    func configure(with homeViewModel: HomeViewModel) {
        viewModel.update(from: homeViewModel)
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
            FoodRecord(title: "Title1", mealType: 3, id: docRef.documentID, userID: UserProfileViewModel.shared.user.id,
                       date: Timestamp(date: currentDate),
                       nutritionFacts: NutritionFacts(
                        weight: Nutrient(value: 50, unit: "g"),
                        calories: Nutrient(value: 50, unit: "kcal"),
                        carbs: Nutrient(value: 8, unit: "g"),
                        fats: Nutrient(value: 1, unit: "g"),
                        protein: Nutrient(value: 2, unit: "g"))), at: docRef)
//        let fakeNutrition = TotalNutrition(date: Timestamp(date: currentDate), totalCalories: 0, totalCarbs: 0, totalProtein: 0, totalFats: 0)
//        var nutritionArray: [TotalNutrition] = []
//        for i in 0..<7 {
//            if let previousDate = Calendar.current.date(byAdding: .day, value: -i, to: currentDate) {
//                let nutrition = TotalNutrition(date: Timestamp(date: previousDate), totalCalories: 0, totalCarbs: 0, totalProtein: 0, totalFats: 0)
//                nutritionArray.insert(nutrition, at: 0) // 將新的 nutrition 插入到陣列的最前面，這樣最後一筆資料是今天
//            }
//        }
//         let docRef = FirebaseManager.shared.newDocument(of: FirestoreEndpoint.users)
//         FirebaseManager().setData(User(id: docRef.documentID, createdTime: Timestamp(date: Date()),
//                                       name: "楊芮瑊", avatarUrl: nil, gender: 1, birthday: "2000-03-06",
//                                       height: 158, weightRecord: [WeightRecord(createdTime: Timestamp(date: Date()), weight: 50)],
//                                       activity: 1, target: 0, totalNutrition: nutritionArray,
//                                       friends: [Friend(userID: "123123123", addedAt: Timestamp(date: Date()), status: "accepted")]), at: docRef)
    }
}
