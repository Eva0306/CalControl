//
//  WeightRecordDetailCell.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/26.
//

import UIKit

class WeightRecordDetailCell: BaseCardTableViewCell {
    
    static let identifier = "WeightRecordDetailCell"
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.text = "date"
        label.textAlignment = .center
        label.font = UIFont(name: "Helvetica Neue", size: 22)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var weightLabel: UILabel = {
        let label = UILabel()
        label.text = "weight"
        label.textAlignment = .center
        label.font = UIFont(name: "Helvetica Neue", size: 32)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var unitLabel: UILabel = {
        let label = UILabel()
        label.text = "kg"
        label.textAlignment = .center
        label.font = UIFont(name: "Helvetica Neue", size: 22)
        label.numberOfLines = 1
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with weightRecord: WeightRecord) {
        timeLabel.text = WeightRecordDetailCell.dateFormatter.string(from: weightRecord.createdTime.dateValue())
        weightLabel.text = String(format: "%.1f", weightRecord.weight)
    }
    
    private func setupView() {
        let stackView = UIStackView(arrangedSubviews: [timeLabel, weightLabel, unitLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        innerContentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: innerContentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: innerContentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: innerContentView.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: innerContentView.topAnchor, constant: 20)
        ])
    }
    
}
