//
//  WaterRecordCell.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/17.
//

import UIKit
import Combine
import FirebaseFirestore

class WaterRecordCell: BaseCardTableViewCell {
    
    static let identifier = "WaterRecordCell"
    
    var viewModel = WaterRecordViewModel()
    private var subscriptions = Set<AnyCancellable>()
    
    var currentDate = globalCurrentDate
    
    private let totalCups = 10
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(WaterCupCell.self, forCellWithReuseIdentifier: WaterCupCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "水"
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.text = "0 ml"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
        addBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        let separatorLine = UIView()
        separatorLine.backgroundColor = .systemGray5
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
            collectionView.heightAnchor.constraint(equalToConstant: 130)
        ])
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.2),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(0.2)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        group.interItemSpacing = .fixed(25)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 15
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    // MARK: - Configure Cell
    func configure(for date: Date) {
        currentDate = date
        viewModel.fetchWaterRecord(for: date)
    }
    
    // MARK: - bind ViewModel
    private func addBindings() {
        viewModel.$currentWaterIntake
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
                self?.updateWaterIntakeLabel()
            }
            .store(in: &subscriptions)
    }
    
    private func updateWaterIntakeLabel() {
        let totalWaterAmount = viewModel.totalWaterAmount
        amountLabel.text = "\(totalWaterAmount) ml"
    }
}

// MARK: - UICollectionViewDataSource
extension WaterRecordCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalCups
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: WaterCupCell = collectionView.dequeueReusableCell(
            withIdentifier: WaterCupCell.identifier, for: indexPath
        )
        if indexPath.item < viewModel.currentWaterIntake {
            cell.configure(as: .filled)
        } else if indexPath.item == viewModel.currentWaterIntake {
            cell.configure(as: .plus)
        } else {
            cell.configure(as: .empty)
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension WaterRecordCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 && viewModel.currentWaterIntake > 0 {
            viewModel.updateWaterIntake(date: currentDate, for: 0)
        } else {
            viewModel.updateWaterIntake(date: currentDate, for: indexPath.item + 1)
        }
    }
}
