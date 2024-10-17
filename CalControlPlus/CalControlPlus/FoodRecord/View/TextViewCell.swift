//
//  TextViewCell.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/15.
//

import UIKit

class TextViewCell: BaseCardTableViewCell {
    
    static let identifier = "TextViewCell"
    
    private lazy var foodLabel: UILabel = {
        let label = UILabel()
        label.text = "Food"
        label.textColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return .white
            default:
                return .darkGray
            }
        }
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 1
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    private lazy var portionLabel: UILabel = {
        let label = UILabel()
        label.text = "one"
        label.textColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return .white
            default:
                return .darkGray
            }
        }
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
    
    var addStoredFood: ((_ food: String, _ portion: String) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(food: FoodItem) {
        self.foodLabel.text = food.name
        self.portionLabel.text = food.portion
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
        guard let food = foodLabel.text, let portion = portionLabel.text else { return }
        addStoredFood?(food, portion)
    }
}
