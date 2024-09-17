//
//  NutritionFactsCell.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/13.
//

import UIKit

class NutritionFactsCell: BaseCardTableViewCell {
    
    private let nutritionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(nutritionFacts: NutritionFacts) {
        setupView(with: nutritionFacts)
    }
    
    private func setupView(with nutritionFacts: NutritionFacts) {
        innerContentView.addSubview(nutritionStackView)
        
        NSLayoutConstraint.activate([
            nutritionStackView.leadingAnchor.constraint(equalTo: innerContentView.leadingAnchor, constant: 16),
            nutritionStackView.trailingAnchor.constraint(equalTo: innerContentView.trailingAnchor, constant: -16),
            nutritionStackView.topAnchor.constraint(equalTo: innerContentView.topAnchor, constant: 8),
            nutritionStackView.bottomAnchor.constraint(equalTo: innerContentView.bottomAnchor, constant: -8)
        ])
        
        let facts = [
            ("份量", "\(nutritionFacts.weight.value) \(nutritionFacts.weight.unit)"),
            ("熱量", "\(nutritionFacts.calories.value) \(nutritionFacts.calories.unit)"),
            ("碳水化合物", "\(nutritionFacts.carbs.value) \(nutritionFacts.carbs.unit)"),
            ("脂質", "\(nutritionFacts.fats.value) \(nutritionFacts.fats.unit)"),
            ("蛋白質", "\(nutritionFacts.protein.value) \(nutritionFacts.protein.unit)")
        ]
        
        for (name, value) in facts {
            let rowStackView = createRowStackView(name: name, value: value)
            nutritionStackView.addArrangedSubview(rowStackView)
        }
    }
    
    private func createRowStackView(name: String, value: String) -> UIStackView {
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.textAlignment = .right
        
        let rowStackView = UIStackView(arrangedSubviews: [nameLabel, valueLabel])
        rowStackView.axis = .horizontal
        rowStackView.distribution = .fill
        rowStackView.spacing = 8
        
        return rowStackView
    }
}
