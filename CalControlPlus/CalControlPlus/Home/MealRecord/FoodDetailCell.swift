//
//  FoodDetailCell.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/26.
//

import UIKit

class FoodDetailCell: BaseCardTableViewCell {
    
    static let identifier = "FoodDetailCell"
    var isEditingMode: Bool = false {
            didSet {
                updateEditingState()
            }
        }
    
    var originalFoodRecord: FoodRecord?
    var valueTextFields: [String: UITextField] = [:]
    
    lazy var titleTextField: UITextField = {
        let tf = UITextField()
        tf.text = "Food name"
        tf.textAlignment = .center
        tf.borderStyle = isEditingMode ? .roundedRect : .none
        tf.isUserInteractionEnabled = isEditingMode
        tf.font = UIFont(name: "Helvetica Neue", size: 32)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let nutritionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with foodRecord: FoodRecord) {
        self.originalFoodRecord = foodRecord
        titleTextField.text = foodRecord.title ?? "Food name"
        
        let facts = [
            ("份量", foodRecord.nutritionFacts.weight.value, foodRecord.nutritionFacts.weight.unit),
            ("熱量", foodRecord.nutritionFacts.calories.value, foodRecord.nutritionFacts.calories.unit),
            ("碳水化合物", foodRecord.nutritionFacts.carbs.value, foodRecord.nutritionFacts.carbs.unit),
            ("脂質", foodRecord.nutritionFacts.fats.value, foodRecord.nutritionFacts.fats.unit),
            ("蛋白質", foodRecord.nutritionFacts.protein.value, foodRecord.nutritionFacts.protein.unit)
        ]
        
        nutritionStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (name, value, unit) in facts {
            let rowStackView = createRowStackView(name: name, value: value, unit: unit)
            nutritionStackView.addArrangedSubview(rowStackView)
        }
    }
    
    private func setupView() {
        innerContentView.addSubview(titleTextField)
        innerContentView.addSubview(nutritionStackView)
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: innerContentView.topAnchor, constant: 10),
            titleTextField.leadingAnchor.constraint(equalTo: innerContentView.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: innerContentView.trailingAnchor, constant: -16),
            
            nutritionStackView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            nutritionStackView.leadingAnchor.constraint(equalTo: innerContentView.leadingAnchor, constant: 16),
            nutritionStackView.trailingAnchor.constraint(equalTo: innerContentView.trailingAnchor, constant: -16),
            nutritionStackView.bottomAnchor.constraint(equalTo: innerContentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func createRowStackView(name: String, value: Double, unit: String) -> UIStackView {
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.textAlignment = .left
        
        let valueTextField = UITextField()
        valueTextField.text = "\(value)"
        valueTextField.textAlignment = .right
        valueTextField.borderStyle = isEditingMode ? .roundedRect : .none
        valueTextField.isUserInteractionEnabled = isEditingMode
        valueTextField.keyboardType = .decimalPad
        valueTextField.translatesAutoresizingMaskIntoConstraints = false
        valueTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        valueTextField.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        valueTextFields[name] = valueTextField
        
        let unitLabel = UILabel()
        unitLabel.text = unit
        unitLabel.textAlignment = .left
        
        let valueStackView = UIStackView(arrangedSubviews: [valueTextField, unitLabel])
        valueStackView.axis = .horizontal
        valueStackView.distribution = .fill
        valueStackView.spacing = 8
        valueStackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let rowStackView = UIStackView(arrangedSubviews: [nameLabel, valueStackView])
        rowStackView.axis = .horizontal
        rowStackView.distribution = .fill
        rowStackView.spacing = 8
        
        return rowStackView
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        print("Text changed: \(textField.text ?? "")")
    }
    
    private func updateEditingState() {
        for case let rowStackView as UIStackView in nutritionStackView.arrangedSubviews {
            for case let valueTextField as UITextField in rowStackView.arrangedSubviews[1].subviews {
                valueTextField.isUserInteractionEnabled = isEditingMode
                valueTextField.borderStyle = isEditingMode ? .roundedRect : .none
            }
        }
        titleTextField.isUserInteractionEnabled = isEditingMode
        titleTextField.borderStyle = isEditingMode ? .roundedRect : .none
    }
}

extension FoodDetailCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
