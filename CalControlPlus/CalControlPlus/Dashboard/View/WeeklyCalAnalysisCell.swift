//
//  WeeklyCalAnalysisCell.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/19.
//

import UIKit
import SwiftUI

class WeeklyCalAnalysisCell: BaseCardTableViewCell {
    
    static let identifier = "WeeklyCalAnalysisCell"
    
    private var hostingController: UIHostingController<WeeklyCalAnalysisView>?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupHostingController()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupHostingController()
    }
    
    private func setupHostingController() {
        let weeklyCalAnalysisView = WeeklyCalAnalysisView(basicGoal: 1000,
                                                    foodValue: 750,
                                                    exerciseValue: 0,
                                                   netCalories: 250,
                                                   bargetValue: 0,
                                                    threshold: 0.8,
                                                    weeklyCaloriesData: [
                                                     ("Sun", 0.8),
                                                     ("Mon", 0.7),
                                                     ("Tue", 0.7),
                                                     ("Wed", 0.7),
                                                     ("Thu", 0.94),
                                                     ("Fri", 0.6),
                                                     ("Sat", 0.6)
                                                    ]
                                 )
        
        hostingController = UIHostingController(rootView: weeklyCalAnalysisView)
        
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
    
    func configure() {

    }
}
