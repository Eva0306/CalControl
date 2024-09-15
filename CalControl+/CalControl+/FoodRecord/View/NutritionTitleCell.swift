//
//  NutritionTitleCell.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/13.
//

import UIKit

class NutritionTitleCell: BaseCardTableViewCell, UITextFieldDelegate {
    
    lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.placeholder = "Enter food name"
        textField.font = UIFont(name: "Helvetica Neue", size: 30)
        textField.textAlignment = .center
        textField.borderStyle = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        button.addTarget(self, action: #selector(editFoodName), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(title: String?) {
        if let title = title {
            titleTextField.text = title
            titleTextField.isUserInteractionEnabled = false
        } else {
            titleTextField.text = ""
            titleTextField.placeholder = "Enter food name"
        }
    }
    
    private func setupView() {
        innerContentView.addSubview(titleTextField)
        innerContentView.addSubview(bottomLine)
        innerContentView.addSubview(editButton)
        
        NSLayoutConstraint.activate([
            titleTextField.leadingAnchor.constraint(equalTo: innerContentView.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: innerContentView.trailingAnchor, constant: -16),
            titleTextField.topAnchor.constraint(equalTo: innerContentView.topAnchor, constant: 16),
            titleTextField.bottomAnchor.constraint(equalTo: innerContentView.bottomAnchor, constant: -16),
            
            bottomLine.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            bottomLine.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            bottomLine.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 4),
            bottomLine.heightAnchor.constraint(equalToConstant: 1),
            
            editButton.trailingAnchor.constraint(equalTo: innerContentView.trailingAnchor, constant: -16),
            editButton.centerYAnchor.constraint(equalTo: innerContentView.centerYAnchor),
            editButton.widthAnchor.constraint(equalToConstant: 40),
            editButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc private func editFoodName() {
        titleTextField.isUserInteractionEnabled = true
        bottomLine.isHidden = false
        titleTextField.becomeFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        bottomLine.isHidden = true
        textField.isUserInteractionEnabled = false
    }
}
