//
//  FoodRecordCell.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/19.
//

import UIKit

class FoodRecordCell: BaseCardTableViewCell {
    
    static let identifier = "FoodRecordCell"
    
    private var foodRecord: FoodRecord?
    
    private lazy var foodTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.tintColor = .darkGray
        label.text = ""
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var foodImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "fork.knife.circle")
        iv.alpha = 0.8
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 8
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupInnerContentView() {
        contentView.addSubview(super.innerContentView)
        NSLayoutConstraint.activate([
            innerContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            innerContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            innerContentView.topAnchor.constraint(equalTo: contentView.topAnchor),
            innerContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    override func prepareForReuse() {
        foodTitleLabel.text = ""
        foodImage.image = UIImage(systemName: "fork.knife.circle")
        foodImage.alpha = 0.8
    }
    
    private func setupView() {
        innerContentView.addSubview(foodTitleLabel)
        innerContentView.addSubview(foodImage)
        
        NSLayoutConstraint.activate([
            foodTitleLabel.leadingAnchor.constraint(equalTo: innerContentView.leadingAnchor, constant: 20),
            foodTitleLabel.centerYAnchor.constraint(equalTo: innerContentView.centerYAnchor),
            
            foodImage.topAnchor.constraint(equalTo: innerContentView.topAnchor, constant: 10),
            foodImage.bottomAnchor.constraint(equalTo: innerContentView.bottomAnchor, constant: -10),
            foodImage.trailingAnchor.constraint(equalTo: innerContentView.trailingAnchor, constant: -20),
            foodImage.widthAnchor.constraint(equalToConstant: 50),
            foodImage.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func configure(with foodRecord: FoodRecord) {
        foodTitleLabel.text = foodRecord.title
        if let imageUrl = foodRecord.imageUrl {
            foodImage.loadImage(with: imageUrl)
            foodImage.alpha = 1.0
        }
    }
}
