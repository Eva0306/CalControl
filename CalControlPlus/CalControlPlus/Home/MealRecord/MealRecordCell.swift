//
//  MealRecordCell.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/19.
//

import UIKit

class MealRecordCell: BaseCardTableViewCell {
    
    static let identifier = "MealRecordCell"
    
    private var isExpanded: Bool = false {
        didSet {
            print("====isExpanded: ", isExpanded)
            updateTableViewHeight()
        }
    }
    
//    private var tableViewHeightConstraint: NSLayoutConstraint!
    
    private var foodRecords: [FoodRecord] = []
    
    private lazy var mealRecordTableView: UITableView = {
        let tv = UITableView()
        tv.dataSource = self
//        tv.delegate = self
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.isScrollEnabled = false
        tv.showsVerticalScrollIndicator = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(FoodRecordCell.self, forCellReuseIdentifier: FoodRecordCell.identifier)
        return tv
    }()
    
    private lazy var mealTypeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.tintColor = .darkGray
        label.text = "meal type"
        label.textAlignment = .left
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        addTapGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        innerContentView.addSubview(mealTypeLabel)
        innerContentView.addSubview(mealRecordTableView)
        
        NSLayoutConstraint.activate([
            mealTypeLabel.topAnchor.constraint(equalTo: innerContentView.topAnchor, constant: 16),
            mealTypeLabel.leadingAnchor.constraint(equalTo: innerContentView.leadingAnchor, constant: 20),
            mealTypeLabel.trailingAnchor.constraint(equalTo: innerContentView.trailingAnchor, constant: -10),
            
            mealRecordTableView.topAnchor.constraint(equalTo: mealTypeLabel.bottomAnchor, constant: 10),
            mealRecordTableView.bottomAnchor.constraint(equalTo: innerContentView.bottomAnchor, constant: -10),
            mealRecordTableView.leadingAnchor.constraint(equalTo: innerContentView.leadingAnchor, constant: 20),
            mealRecordTableView.trailingAnchor.constraint(equalTo: innerContentView.trailingAnchor, constant: -10)
        ])
//        tableViewHeightConstraint = mealRecordTableView.heightAnchor.constraint(equalToConstant: 0)
//        tableViewHeightConstraint.isActive = true
    }
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleExpand))
        mealTypeLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc private func toggleExpand() {
        isExpanded.toggle()
    }
    
    private func updateTableViewHeight() {
        // 根据 isExpanded 修改 mealRecordTableView 的高度
//        let newHeight = isExpanded ? mealRecordTableView.contentSize.height : 0
//        tableViewHeightConstraint.constant = newHeight
//        print(tableViewHeightConstraint.constant)
        mealRecordTableView.layoutIfNeeded()
        
        // 通知外层的 UITableView 更新行高
        guard let tableView = superview as? UITableView else { return }
        
        UIView.animate(withDuration: 0.3) {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    func configure(foodRecords: [FoodRecord]) {
        self.foodRecords = foodRecords
//        mealRecordTableView.reloadData()
    }
}

// MARK: - TableView DataSource
extension MealRecordCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        foodRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: FoodRecordCell.identifier, for: indexPath) as! FoodRecordCell
        // swiftlint:enable force_cast
        let foodRecord = foodRecords[indexPath.row]
        cell.configure(with: foodRecord)
        return cell
    }
    
}

extension MealRecordCell {
    override func prepareForReuse() {
        isExpanded = false
    }
}
