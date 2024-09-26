//
//  DeleteButtonCell.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/26.
//

import UIKit

class DeleteButtonCell: BaseCardTableViewCell {
    
    static let identifier = "DeleteButtonCell"
    
    lazy var deleteButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("刪除", for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = .mainRed
        btn.layer.cornerRadius = 5
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
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
        innerContentView.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: innerContentView.topAnchor, constant: 0),
            deleteButton.leadingAnchor.constraint(equalTo: innerContentView.leadingAnchor, constant: 0),
            deleteButton.trailingAnchor.constraint(equalTo: innerContentView.trailingAnchor, constant: 0),
            deleteButton.bottomAnchor.constraint(equalTo: innerContentView.bottomAnchor, constant: 0),
            deleteButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
