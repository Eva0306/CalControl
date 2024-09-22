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
        // tv.delegate = self
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(WeeklyCalAnalysisCell.self, forCellReuseIdentifier: WeeklyCalAnalysisCell.identifier)
        tv.register(WeeklyNutriAnalysisCell.self, forCellReuseIdentifier: WeeklyNutriAnalysisCell.identifier)
        return tv
    }()
    
    var homeViewModel: HomeViewModel?
    var dashboardViewModel: DashboardViewModel?
    private var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(resource: .background)

        if let navController = self.tabBarController?.viewControllers?.first as? UINavigationController,
           let homeVC = navController.topViewController as? HomeVC {
            
            self.homeViewModel = homeVC.homeViewModel
            
        } else {
            print("Failed to get HomeVC")
        }
        
        dashboardViewModel = DashboardViewModel(userProfileViewModel: UserProfileViewModel.shared)
        addBindings()
        dashboardViewModel?.fetchWeeklyFoodRecords()
        
        setupView()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(foodRecordDidChange(_:)),
            name: Notification.Name("FoodRecordDidChange"),
            object: nil)
    }
    
    @objc private func foodRecordDidChange(_ notification: Notification){
        dashboardViewModel?.fetchWeeklyFoodRecords()
    }
    
    private func setupView() {
        
        view.addSubview(dashboardTableView)
        
        NSLayoutConstraint.activate([
            dashboardTableView.topAnchor.constraint(equalTo: view.topAnchor),
            dashboardTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dashboardTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dashboardTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func addBindings() {
//        dashboardViewModel?.$foodRecords
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] _ in
//                self?.dashboardTableView.reloadData()
//            }
//            .store(in: &subscriptions)
        dashboardViewModel?.$weeklyTotalNutrition
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
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.item == 0 {
            // swiftlint:disable force_cast line_length
            let cell = tableView.dequeueReusableCell(withIdentifier: WeeklyCalAnalysisCell.identifier, for: indexPath) as! WeeklyCalAnalysisCell
            // swiftlint:enable force_cast line_length
            if let dashboardViewModel = dashboardViewModel,
               let homeViewModel = homeViewModel {
                cell.configure(with: dashboardViewModel, homeViewModel)
            }
            return cell
        } else if indexPath.item == 1 {
            // swiftlint:disable force_cast line_length
            let cell = tableView.dequeueReusableCell(withIdentifier: WeeklyNutriAnalysisCell.identifier, for: indexPath) as! WeeklyNutriAnalysisCell
            // swiftlint:enable force_cast line_length
            if let dashboardViewModel = dashboardViewModel,
               let homeViewModel = homeViewModel {
                cell.configure(with: dashboardViewModel, homeViewModel)
            }
            return cell
        }
        return UITableViewCell()
    }
}
