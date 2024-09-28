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
        let dailyAnalysisView = DailyAnalysisView(viewModel: viewModel)
        
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
}
