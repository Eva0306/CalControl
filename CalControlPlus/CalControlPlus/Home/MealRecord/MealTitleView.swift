//
//  MealTitleView.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/21.
//

import UIKit

// MARK: - MealTitleViewDelegate Protocol
protocol MealTitleViewDelegate: AnyObject {
    func mealTitleView(_ mealTitleView: MealTitleView, didPressTag tag: Int, isExpand: Bool)
}

// MARK: - MealTitleView Class
class MealTitleView: UITableViewHeaderFooterView {
    
    static let identifier = "MealTitleView"
    
    weak var delegate: MealTitleViewDelegate?
    private var buttonTag: Int!
    private var isExpand: Bool!
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.text = "food name"
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var arrowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("↑", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(pressExpandButton(_:)), for: .touchUpInside)
        return button
    }()
    
    let innerContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .cellBackground
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(innerContentView)
        innerContentView.addSubview(titleLabel)
        innerContentView.addSubview(arrowButton)
        
        NSLayoutConstraint.activate([
            innerContentView.topAnchor.constraint(equalTo: contentView.topAnchor),
            innerContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            innerContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            innerContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: innerContentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: innerContentView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: arrowButton.leadingAnchor, constant: -10),
            titleLabel.bottomAnchor.constraint(equalTo: innerContentView.bottomAnchor, constant: -10),
            
            arrowButton.centerYAnchor.constraint(equalTo: innerContentView.centerYAnchor),
            arrowButton.trailingAnchor.constraint(equalTo: innerContentView.trailingAnchor, constant: -10),
            arrowButton.widthAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    @objc private func pressExpandButton(_ sender: UIButton) {
        isExpand.toggle()
        let newTitle = isExpand ? "↓" : "↑"
        arrowButton.setTitle(newTitle, for: .normal)
        
        delegate?.mealTitleView(self, didPressTag: buttonTag, isExpand: isExpand)
    }
    
    func configure(title: String, tag: Int, isExpanded: Bool) {
        titleLabel.text = title
        buttonTag = tag
        isExpand = isExpanded
        let newTitle = isExpand ? "↓" : "↑"
        arrowButton.setTitle(newTitle, for: .normal)
    }
}
