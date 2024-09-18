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
    
    private var hostingController: UIHostingController<DailyAnalysisView>?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupHostingController()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupHostingController()
    }
    
    private func setupHostingController() {
        let dailyAnalysisView = DailyAnalysisView(basicGoal: 2000, foodValue: 1500, exerciseValue: 500,
                                            carbohydrateCurrent: 50, carbohydrateTotal: 162, proteinCurrent: 30, proteinTotal: 65, fatCurrent: 22, fatTotal: 40)
        
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
