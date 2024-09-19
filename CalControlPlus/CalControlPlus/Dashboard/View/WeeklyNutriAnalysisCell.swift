//
//  WeeklyNutriAnalysisCell.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/19.
//

import UIKit
import SwiftUI

class WeeklyNutriAnalysisCell: BaseCardTableViewCell {
    
    static let identifier = "WeeklyNutriAnalysisCell"
    
    private var hostingController: UIHostingController<WeeklyNutriAnalysisView>?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupHostingController()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupHostingController()
    }
    
    private func setupHostingController() {
        let dailyAnalysisView = WeeklyNutriAnalysisView(
            dailyData: [
                WANutriData(day: "Sun", carbohydrate: 0.3, fat: 0.3, protein: 0.4),
                WANutriData(day: "Mon", carbohydrate: 0.3, fat: 0.3, protein: 0.4),
                WANutriData(day: "Tue", carbohydrate: 0.4, fat: 0.2, protein: 0.4),
                WANutriData(day: "Wed", carbohydrate: 0.2, fat: 0.4, protein: 0.4),
                WANutriData(day: "Thu", carbohydrate: 0.4, fat: 0.3, protein: 0.3),
                WANutriData(day: "Fri", carbohydrate: 0.3, fat: 0.3, protein: 0.4),
                WANutriData(day: "Sat", carbohydrate: 0.3, fat: 0.3, protein: 0.4)
            ],
            todayNutrition: [0.33, 0.33, 0.34]
        )
        
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
    
    func configure() {

    }
}


