//
//  DailyAnalysisCell.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/18.
//

import UIKit
import SwiftUI

class DailyAnalysisCell: BaseCardTableViewCell {
    
    static let identifier = "DailyAnalysisCell"
    
    var basicGoal: Int = 0
    var carbohydrateTotal: Double = 0
    var proteinTotal: Double = 0
    var fatTotal: Double = 0
    
    private var hostingController: UIHostingController<DailyAnalysisView>?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupHostingController(foodValue: Int, exerciseValue: Int, carbohydrateCurrent: Double,
                                        proteinCurrent: Double, fatCurrent: Double) {
        let dailyAnalysisView = DailyAnalysisView(basicGoal: basicGoal,
                                                  foodValue: foodValue,
                                                  exerciseValue: exerciseValue,
                                                  carbohydrateCurrent: carbohydrateCurrent,
                                                  carbohydrateTotal: carbohydrateTotal,
                                                  proteinCurrent: proteinCurrent,
                                                  proteinTotal: proteinTotal,
                                                  fatCurrent: fatCurrent,
                                                  fatTotal: fatTotal)
        
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
        setupHostingController(foodValue: Int(viewModel.totalCalories),
                               exerciseValue: viewModel.exerciseValue,
                               carbohydrateCurrent: viewModel.totalCarbs,
                               proteinCurrent: viewModel.totalProtein,
                               fatCurrent: viewModel.totalFats)
        
        basicGoal = viewModel.userSettings.basicGoal
        carbohydrateTotal = viewModel.userSettings.carbohydrateTotal
        proteinTotal = viewModel.userSettings.proteinTotal
        fatTotal = viewModel.userSettings.fatTotal
    }
}
