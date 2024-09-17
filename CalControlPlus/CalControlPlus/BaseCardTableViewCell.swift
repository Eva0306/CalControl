//
//  BaseCardTableViewCell.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/14.
//

import UIKit

class BaseCardTableViewCell: UITableViewCell {
    
    let innerContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = .clear
        setupInnerContentView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupInnerContentView() {
        contentView.addSubview(innerContentView)
        
        NSLayoutConstraint.activate([
            innerContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            innerContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            innerContentView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            innerContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
}
