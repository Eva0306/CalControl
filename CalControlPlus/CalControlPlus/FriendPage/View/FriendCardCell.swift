//
//  FriendCardCell.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/23.
//

import UIKit

class FriendCardCell: BaseCardTableViewCell {
    
    static let identifier = "FriendCardCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        
    }
    
}
