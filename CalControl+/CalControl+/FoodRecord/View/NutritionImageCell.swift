//
//  NutritionImageCell.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/13.
//

import UIKit

class NutritionImageCell: BaseCardTableViewCell {
    
    private let foodImageView = UIImageView()
    
    private let colorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightOrg
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica Neue", size: 30)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(image: UIImage?, name: String?) {
        if let image = image {
            setupImageView(image)
        } else if let name = name {
            setupNameView(name)
        }
    }
    
    private func setupImageView(_ image: UIImage) {
        
        foodImageView.image = image
        foodImageView.contentMode = .scaleAspectFit
        foodImageView.translatesAutoresizingMaskIntoConstraints = false
        foodImageView.clipsToBounds = true
        
        innerContentView.addSubview(foodImageView)
        
        NSLayoutConstraint.activate([
            foodImageView.leadingAnchor.constraint(equalTo: innerContentView.leadingAnchor),
            foodImageView.trailingAnchor.constraint(equalTo: innerContentView.trailingAnchor),
            foodImageView.topAnchor.constraint(equalTo: innerContentView.topAnchor),
            foodImageView.bottomAnchor.constraint(equalTo: innerContentView.bottomAnchor),
            foodImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 400)
        ])
    }
    
    private func setupNameView(_ name: String) {
        nameLabel.text = name
        
        innerContentView.addSubview(colorView)
        
        NSLayoutConstraint.activate([
            colorView.leadingAnchor.constraint(equalTo: innerContentView.leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: innerContentView.trailingAnchor),
            colorView.topAnchor.constraint(equalTo: innerContentView.topAnchor),
            colorView.bottomAnchor.constraint(equalTo: innerContentView.bottomAnchor),
            colorView.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        colorView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: colorView.centerXAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: colorView.centerYAnchor)
        ])
        
    }
}
