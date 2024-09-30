//
//  WaterCupCell.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/17.
//

import UIKit

enum CupType {
    case empty, filled, plus
}

class WaterCupCell: UICollectionViewCell {
    
    static let identifier = "WaterCupCell"
    
    private let emptyWaterView = EmptyWaterView()
    private let fillWaterView = FillWaterView()
    private let plusImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "plus.circle.fill"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(emptyWaterView)
        contentView.addSubview(fillWaterView)
        contentView.addSubview(plusImageView)
        
        emptyWaterView.translatesAutoresizingMaskIntoConstraints = false
        fillWaterView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            emptyWaterView.topAnchor.constraint(equalTo: contentView.topAnchor),
            emptyWaterView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emptyWaterView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emptyWaterView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            fillWaterView.topAnchor.constraint(equalTo: contentView.topAnchor),
            fillWaterView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            fillWaterView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            fillWaterView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            plusImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            plusImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            plusImageView.widthAnchor.constraint(equalToConstant: 20),
            plusImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
//        emptyWaterView.isHidden = true
        fillWaterView.isHidden = true
        plusImageView.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(as type: CupType) {
        switch type {
        case .empty:
            emptyWaterView.isHidden = false
            fillWaterView.isHidden = true
            plusImageView.isHidden = true
        case .filled:
            fillWaterView.isHidden = false
            emptyWaterView.isHidden = true
            plusImageView.isHidden = true
            fillWaterView.animateWaveView()
        case .plus:
            emptyWaterView.isHidden = false
            fillWaterView.isHidden = true
            plusImageView.isHidden = false
        }
    }
}
