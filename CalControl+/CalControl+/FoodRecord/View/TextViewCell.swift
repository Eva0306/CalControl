//
//  TextViewCell.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/15.
//

import UIKit

class TextViewCell: BaseCardTableViewCell {
    
    private lazy var foodLabel: UILabel = {
        let label = UILabel()
        label.text = "Food"
        label.textColor = .darkGray
        label.textAlignment = .left
        label.font = UIFont(name: "Helvetica Neue", size: 16)
        label.numberOfLines = 1
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    private lazy var portionLabel: UILabel = {
        let label = UILabel()
        label.text = "one"
        label.textColor = .darkGray
        label.textAlignment = .center
        label.font = UIFont(name: "Helvetica Neue", size: 16)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var addButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .mainGreen
        btn.setImage(UIImage(systemName: "plus"), for: .normal)
        btn.tintColor = .white
        btn.layer.cornerRadius = 10
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(addFood), for: .touchUpInside)
        return btn
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(food: [String]) {
        guard food.count > 1 else { return }
        self.foodLabel.text = food[0]
        self.portionLabel.text = food[1]
    }
    
    private func setupView() {
        let foodStackView = UIStackView(arrangedSubviews: [foodLabel, portionLabel, addButton])
        foodStackView.axis = .horizontal
        foodStackView.alignment = .center
        foodStackView.spacing = 8
        foodStackView.distribution = .fill
        foodStackView.translatesAutoresizingMaskIntoConstraints = false
        
        innerContentView.addSubview(foodStackView)
        
        NSLayoutConstraint.activate([
            foodStackView.leadingAnchor.constraint(equalTo: innerContentView.leadingAnchor, constant: 16),
            foodStackView.trailingAnchor.constraint(equalTo: innerContentView.trailingAnchor, constant: -16),
            foodStackView.topAnchor.constraint(equalTo: innerContentView.topAnchor, constant: 8),
            foodStackView.bottomAnchor.constraint(equalTo: innerContentView.bottomAnchor, constant: -8),
            
            addButton.widthAnchor.constraint(equalToConstant: 40),
            addButton.heightAnchor.constraint(equalTo: addButton.widthAnchor)
        ])
    }
    
    @objc private func addFood() {
        print("Add Food")
    }
}
