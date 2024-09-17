//
//  WaterRecordCell.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/17.
//

import UIKit

class WaterRecordCell: BaseCardTableViewCell {
    
    static let identifier = "WaterRecordCell"
    
    private let totalCups = 8
    private var currentWaterIntake = 0 {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private let emptyCupImage = UIImage(named: "emptyCup")!
    private let filledCupImage = UIImage(named: "filledCup")!
    private let plusCupImage = UIImage(named: "plusCup")!
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(WaterCupCell.self, forCellWithReuseIdentifier: WaterCupCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "水"
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.text = "0 ml"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        let separatorLine = UIView()
        separatorLine.backgroundColor = .systemGray5
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        
        innerContentView.addSubview(titleLabel)
        innerContentView.addSubview(amountLabel)
        innerContentView.addSubview(separatorLine)
        innerContentView.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: innerContentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: innerContentView.leadingAnchor, constant: 20),
            
            amountLabel.topAnchor.constraint(equalTo: innerContentView.topAnchor, constant: 10),
            amountLabel.trailingAnchor.constraint(equalTo: innerContentView.trailingAnchor, constant: -20),
            
            separatorLine.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            separatorLine.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 10),
            separatorLine.trailingAnchor.constraint(equalTo: amountLabel.trailingAnchor, constant: -10),
            separatorLine.heightAnchor.constraint(equalToConstant: 1),
            
            collectionView.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: innerContentView.leadingAnchor, constant: 15),
            collectionView.trailingAnchor.constraint(equalTo: innerContentView.trailingAnchor, constant: -15),
            collectionView.bottomAnchor.constraint(equalTo: innerContentView.bottomAnchor, constant: -10),
            collectionView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    // MARK: - Configure Collection View
    func configure(with waterIntake: Int) {
        self.currentWaterIntake = waterIntake
        updateWaterIntakeLabel()
    }
    
    private func updateWaterIntakeLabel() {
        let totalWaterAmount = currentWaterIntake * 250
        amountLabel.text = "\(totalWaterAmount) ml"
    }
}

// MARK: - UICollectionViewDataSource
extension WaterRecordCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalCups
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WaterCupCell.identifier, for: indexPath) as! WaterCupCell
        // swiftlint:enable force_cast
        if indexPath.item < currentWaterIntake {
            cell.configure(with: filledCupImage)
        } else if indexPath.item == currentWaterIntake {
            cell.configure(with: plusCupImage)
        } else {
            cell.configure(with: emptyCupImage)
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension WaterRecordCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 && currentWaterIntake > 0 {
            currentWaterIntake = 0
        } else {
            currentWaterIntake = indexPath.item + 1
        }
        updateWaterIntakeLabel()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 70)
    }
}
