//
//  WeightRecordCell.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/22.
//

import UIKit
import SwiftUI

class WeightRecordCell: BaseCardTableViewCell {
    
    static let identifier = "WeightRecordCell"
    
    private var viewModel = WeightRecordViewModel()
    
    private var hostingController: UIHostingController<WeightRecordView>?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupHostingController()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupHostingController()
    }
    
    private func setupHostingController() {
        let weightRecordView = WeightRecordView(viewModel: viewModel)
        
        hostingController = UIHostingController(rootView: weightRecordView)
        
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
}
