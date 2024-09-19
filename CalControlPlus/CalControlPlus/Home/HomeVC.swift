//
//  HomeVC.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/11.
//

import UIKit
import Combine

class HomeVC: UIViewController {
    
    private lazy var homeTableView: UITableView = {
        let tv = UITableView()
        tv.dataSource = self
        // tv.delegate = self
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.rowHeight = UITableView.automaticDimension
        tv.showsVerticalScrollIndicator = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(WaterRecordCell.self, forCellReuseIdentifier: WaterRecordCell.identifier)
        tv.register(DailyAnalysisCell.self, forCellReuseIdentifier: DailyAnalysisCell.identifier)
        tv.register(MealRecordCell.self, forCellReuseIdentifier: MealRecordCell.identifier)
        return tv
    }()
    
    var viewModel = HomeViewModel()
    private var subscriptions = Set<AnyCancellable>()
    
    var currentDate = Calendar.current.startOfDay(for: Date())

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(resource: .background)
        
        setupView()
        addBindings()
        viewModel.fetchFoodRecord(for: currentDate)
    }
    
    private func setupView() {
        
        view.addSubview(homeTableView)
        
        NSLayoutConstraint.activate([
            homeTableView.topAnchor.constraint(equalTo: view.topAnchor),
            homeTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            homeTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            homeTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func addBindings() {
        viewModel.$foodRecord
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.homeTableView.reloadData()
            }
            .store(in: &subscriptions)
    }
}

// MARK: - TableView DataSource
extension HomeVC: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.item == 0 {
            // swiftlint:disable force_cast
            let cell = tableView.dequeueReusableCell(withIdentifier: DailyAnalysisCell.identifier, for: indexPath) as! DailyAnalysisCell
            // swiftlint:enable force_cast
//            cell.configure(for: currentDate)
            return cell
        } else if indexPath.item == 1 {
            // swiftlint:disable force_cast
            let cell = tableView.dequeueReusableCell(withIdentifier: WaterRecordCell.identifier, for: indexPath) as! WaterRecordCell
            // swiftlint:enable force_cast
            cell.configure(for: currentDate)
            return cell
        } else {
            // swiftlint:disable force_cast
            let cell = tableView.dequeueReusableCell(withIdentifier: MealRecordCell.identifier, for: indexPath) as! MealRecordCell
            // swiftlint:enable force_cast
            let mealType = indexPath.item - 2
            let foodRecords = viewModel.foodRecord.filter { $0.mealType == mealType }
            cell.configure(mealType: mealType, foodRecords: foodRecords)
            return cell
        }
//        return UITableViewCell()
    }
}
