//
//  DashboardVC.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/11.
//

import UIKit
import Combine

class DashboardVC: UIViewController {
    
    private lazy var dashboardTableView: UITableView = {
        let tv = UITableView()
        tv.dataSource = self
        tv.delegate = self
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(WeeklyCalAnalysisCell.self, forCellReuseIdentifier: WeeklyCalAnalysisCell.identifier)
        tv.register(WeeklyNutriAnalysisCell.self, forCellReuseIdentifier: WeeklyNutriAnalysisCell.identifier)
        tv.register(WeightRecordCell.self, forCellReuseIdentifier: WeightRecordCell.identifier)
        return tv
    }()
    
    var homeViewModel: HomeViewModel?
    var dashboardViewModel = DashboardViewModel()
    private var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let navController = self.tabBarController?.viewControllers?.first as? UINavigationController,
           let homeVC = navController.topViewController as? HomeVC {
            
            self.homeViewModel = homeVC.homeViewModel
            
        } else {
            print("Failed to get HomeVC")
        }
        
        addBindings()
        dashboardViewModel.fetchWeeklyFoodRecords()
        dashboardViewModel.addObserver()
        setupView()
    }
    
    private func setupView() {
        view.addSubview(dashboardTableView)
        
        let tabBarHeight = tabBarController?.tabBar.frame.size.height ?? 0
        
        NSLayoutConstraint.activate([
            dashboardTableView.topAnchor.constraint(equalTo: view.topAnchor),
            dashboardTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -tabBarHeight-20),
            dashboardTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dashboardTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func addBindings() {
        dashboardViewModel.$weeklyTotalNutrition
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.dashboardTableView.reloadData()
            }
            .store(in: &subscriptions)
    }
}

// MARK: - TableView DataSource
extension DashboardVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.item == 0 {
            // swiftlint:disable force_cast line_length
            let cell = tableView.dequeueReusableCell(withIdentifier: WeeklyCalAnalysisCell.identifier, for: indexPath) as! WeeklyCalAnalysisCell
            // swiftlint:enable force_cast line_length
            if let homeViewModel = homeViewModel {
                cell.configure(with: dashboardViewModel, homeViewModel)
            }
            return cell
        } else if indexPath.item == 1 {
            // swiftlint:disable force_cast line_length
            let cell = tableView.dequeueReusableCell(withIdentifier: WeeklyNutriAnalysisCell.identifier, for: indexPath) as! WeeklyNutriAnalysisCell
            // swiftlint:enable force_cast line_length
            if let homeViewModel = homeViewModel {
                cell.configure(with: dashboardViewModel, homeViewModel)
            }
            return cell
        } else if indexPath.item == 2 {
            // swiftlint:disable force_cast line_length
            let cell = tableView.dequeueReusableCell(withIdentifier: WeightRecordCell.identifier, for: indexPath) as! WeightRecordCell
            // swiftlint:enable force_cast line_length
            return cell
        }
        return UITableViewCell()
    }
}

extension DashboardVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            performSegue(withIdentifier: "showWeightRecordDetail", sender: self)
        }
    }
}
