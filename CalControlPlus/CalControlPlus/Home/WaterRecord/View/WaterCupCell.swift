//
//  WaterCupCell.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/17.
//

import UIKit

class WaterCupCell: UICollectionViewCell {
    
    static let identifier = "WaterCupCell"
    
    private let cupImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(cupImageView)
        
        NSLayoutConstraint.activate([
            cupImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cupImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            cupImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cupImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with image: UIImage) {
        cupImageView.image = image
    }
}

