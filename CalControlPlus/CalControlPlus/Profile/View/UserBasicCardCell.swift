//
//  UserBasicCardCell.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/23.
//

import UIKit

class UserBasicCardCell: BaseCardTableViewCell {
    
    static let identifier = "UserBasicCardCell"
    
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
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
    
    private func setupView() {
        innerContentView.addSubview(verticalStackView)
        
        NSLayoutConstraint.activate([
            verticalStackView.leadingAnchor.constraint(equalTo: innerContentView.leadingAnchor, constant: 16),
            verticalStackView.trailingAnchor.constraint(equalTo: innerContentView.trailingAnchor, constant: -16),
            verticalStackView.topAnchor.constraint(equalTo: innerContentView.topAnchor, constant: 16),
            verticalStackView.bottomAnchor.constraint(equalTo: innerContentView.bottomAnchor, constant: -16)
        ])
        
        addRow(leftText: "性別", rightView: createTitleAndArrowStack(title: "女"))
        addRow(leftText: "身高", rightView: createTitleAndArrowStack(title: "160 cm"))
        addRow(leftText: "生日", rightView: createTitleAndArrowStack(title: "生日"))
        addRow(leftText: "體重", rightView: createTitleAndArrowStack(title: "50 kg"))
        addRow(leftText: "日常活動量", rightView: createTitleAndArrowStack(title: "身體活動程度正常"))
        addRow(leftText: "目標", rightView: createTitleAndArrowStack(title: "維持體重"))
    }
    
    private func createTitleAndArrowStack(title: String) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = .darkGray
        
        let arrowImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrowImageView.tintColor = .lightGray
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, arrowImageView])
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }
    
    private func addRow(leftText: String, rightView: UIView) {
        let horizontalStackView = UIStackView()
        horizontalStackView.axis = .horizontal
        horizontalStackView.alignment = .center
        horizontalStackView.distribution = .equalSpacing
        horizontalStackView.spacing = 8
        
        let leftLabel = UILabel()
        leftLabel.text = leftText
        leftLabel.font = UIFont.systemFont(ofSize: 16)
        
        horizontalStackView.addArrangedSubview(leftLabel)
        horizontalStackView.addArrangedSubview(rightView)
        
        verticalStackView.addArrangedSubview(horizontalStackView)
    }
}
