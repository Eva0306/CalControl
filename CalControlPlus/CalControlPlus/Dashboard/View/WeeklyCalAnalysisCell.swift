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
    
    private var viewModel = WeeklyAnalysisViewModel()
    
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
        let weeklyCalAnalysisView = WeeklyCalAnalysisView(viewModel: viewModel)
        
        hostingController = UIHostingController(rootView: weeklyCalAnalysisView)
        
        if let hostingController = hostingController {
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            hostingController.view.backgroundColor = .clear
            innerContentView.addSubview(hostingController.view)
            
            NSLayoutConstraint.activate([
                hostingController.view.topAnchor.constraint(equalTo: innerContentView.topAnchor),
                hostingController.view.bottomAnchor.constraint(equalTo: innerContentView.bottomAnchor),
                hostingController.view.leadingAnchor.constraint(equalTo: innerContentView.leadingAnchor),
                hostingController.view.trailingAnchor.constraint(equalTo: innerContentView.trailingAnchor)
            ])
        }
    }
    
    func configure(with dashboardViewModel: DashboardViewModel, _ homeViewModel: HomeViewModel) {
        self.viewModel.update(from: dashboardViewModel, homeViewModel)
    }
}
