//
//  NutritionImageCell.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/13.
//

import UIKit

class NutritionImageCell: BaseCardTableViewCell {
    
    static let identifier = "NutritionImageCell"
    
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
    
    private var isImageMode: Bool = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupImageView()
        setupNameView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(image: UIImage?, name: String?) {
        if let image = image {
            isImageMode = true
            foodImageView.image = image
            showImageView()
        } else {
            isImageMode = false
            nameLabel.text = name ?? "Food"
            showNameView()
        }
    }
    
    func configureCell(image: String?, name: String?) {
        if let image = image {
            isImageMode = true
            foodImageView.loadImage(with: image)
            showImageView()
        } else {
            isImageMode = false
            nameLabel.text = name ?? "Food"
            showNameView()
        }
    }
    
    private func setupImageView() {
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
    
    private func setupNameView() {
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
    
    private func showImageView() {
        foodImageView.isHidden = false
        colorView.isHidden = true
    }
    
    private func showNameView() {
        foodImageView.isHidden = true
        colorView.isHidden = false
    }
}
