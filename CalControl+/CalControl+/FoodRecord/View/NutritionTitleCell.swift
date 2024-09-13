//
//  NutritionTitleCell.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/13.
//

import UIKit

class NutritionTitleCell: UITableViewCell {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        
    }
}
