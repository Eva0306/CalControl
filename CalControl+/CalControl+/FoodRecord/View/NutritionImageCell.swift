//
//  NutritionImageCell.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/13.
//

import UIKit

class NutritionImageCell: UITableViewCell {
    
    lazy var foodImageView: UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        
        foodImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(foodImageView)
        
        NSLayoutConstraint.activate([
            foodImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            foodImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            foodImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            foodImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}


