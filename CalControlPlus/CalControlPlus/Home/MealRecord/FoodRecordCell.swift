//
//  FoodRecordCell.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/19.
//

import UIKit

class FoodRecordCell: UITableViewCell {
    
    static let identifier = "FoodRecordCell"
    
    private var foodRecord: FoodRecord?
    
    private lazy var foodTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.tintColor = .darkGray
        label.text = "food name"
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var foodImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "carrot")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(foodTitleLabel)
        contentView.addSubview(foodImage)
        
        NSLayoutConstraint.activate([
            foodTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            foodTitleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            foodImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            foodImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            foodImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            foodImage.widthAnchor.constraint(equalToConstant: 50),
            foodImage.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func configure(with foodRecord: FoodRecord) {
        foodTitleLabel.text = foodRecord.title
        if let imageUrl = foodRecord.imageUrl {
            foodImage.loadImage(with: imageUrl)
        }
    }
}
