//
//  NutritionFactsCell.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/13.
//

import UIKit

class NutritionFactsCell: UITableViewCell {
    
    lazy var weightLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var calLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var carbsLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var fatsLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var proteinLabel: UILabel = {
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
