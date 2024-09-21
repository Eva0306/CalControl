//
//  HomeVC.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/11.
//

import UIKit
import Combine
import FirebaseCore

class HomeVC: UIViewController {
    
    private lazy var homeTableView: UITableView = {
        let tv = UITableView()
        tv.dataSource = self
        tv.delegate = self
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.sectionFooterHeight = 0
        tv.sectionHeaderHeight = 0
        tv.rowHeight = UITableView.automaticDimension
        tv.showsVerticalScrollIndicator = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(WaterRecordCell.self, forCellReuseIdentifier: WaterRecordCell.identifier)
        tv.register(DailyAnalysisCell.self, forCellReuseIdentifier: DailyAnalysisCell.identifier)
        tv.register(MealTitleView.self, forHeaderFooterViewReuseIdentifier: MealTitleView.identifier)
        tv.register(FoodRecordCell.self, forCellReuseIdentifier: FoodRecordCell.identifier)
        return tv
    }()
    
    var userProfileViewModel: UserProfileViewModel!
    var homeViewModel: HomeViewModel?
    private var subscriptions = Set<AnyCancellable>()
    
    var currentDate = Calendar.current.startOfDay(for: Date())
    var currentUserID = "o0rbDjlpam158hluBnaW"
    
    var mealCellIsExpanded: [Bool] = [false, false, false, false]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(resource: .background)
        
        fetchUser { [weak self] user in
            guard let self = self else { return }
            
            self.userProfileViewModel = UserProfileViewModel(user: user)
            self.homeViewModel = HomeViewModel(userProfileViewModel: self.userProfileViewModel!)
            self.addBindings()
            self.homeViewModel?.fetchFoodRecord(for: currentDate)
        }
        setupView()
        NotificationCenter.default.addObserver(self, selector: #selector(foodRecordDidChange(_:)), name: Notification.Name("FoodRecordDidChange"), object: nil)
    }
    
    @objc private func foodRecordDidChange(_ notification: Notification) {
        homeViewModel?.fetchFoodRecord(for: currentDate)
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
        homeViewModel?.$foodRecords
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.homeTableView.reloadData()
            }
            .store(in: &subscriptions)
    }
    
    private func fetchUser(completion: @escaping (User) -> Void) {
        FirebaseManager.shared.getDocuments(from: .users, where: "id", isEqualTo: currentUserID) { (users: [User]) in
            if let user = users.first {
                completion(user)
            } else {
                print("Error fetching user")
            }
        }
    }
}

// MARK: - TableView DataSource
extension HomeVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 + (homeViewModel?.mealCategories.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 || section == 1 {
            return 1
        } else {
            return mealCellIsExpanded[section - 2] ? (homeViewModel?.foodRecordsByCategory[section - 2].count ?? 0) : 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            // swiftlint:disable force_cast line_length
            let cell = tableView.dequeueReusableCell(withIdentifier: DailyAnalysisCell.identifier, for: indexPath) as! DailyAnalysisCell
            // swiftlint:enable force_cast line_length
            if let homeViewModel = homeViewModel {
                cell.configure(with: homeViewModel)
            }
            return cell
        } else if indexPath.section == 1 {
            // swiftlint:disable force_cast line_length
            let cell = tableView.dequeueReusableCell(withIdentifier: WaterRecordCell.identifier, for: indexPath) as! WaterRecordCell
            // swiftlint:enable force_cast line_length
            cell.configure(for: currentDate)
            return cell
        } else {
            // swiftlint:disable force_cast line_length
            let cell = tableView.dequeueReusableCell(withIdentifier: FoodRecordCell.identifier, for: indexPath) as! FoodRecordCell
            // swiftlint:enable force_cast line_length
            if let homeViewModel = homeViewModel {
                let foodRecord = homeViewModel.foodRecordsByCategory[indexPath.section - 2][indexPath.row]
                cell.configure(with: foodRecord)
            }
            return cell
        }
//        return UITableViewCell()
    }
}

// MARK: - UITableViewDelegate
extension HomeVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section <= 1 {
            return nil
        }
        // swiftlint:disable force_cast line_length
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: MealTitleView.identifier) as! MealTitleView
        // swiftlint:enable force_cast line_length
        headerView.delegate = self
        let isExpanded = self.mealCellIsExpanded[section - 2]
        
        if let homeViewModel = homeViewModel {
            let title = homeViewModel.mealCategories[section - 2]
            headerView.configure(title: title, tag: section - 2, isExpanded: isExpanded)
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section <= 1 {
            return 0
        }
        return 50
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - Meal Title View Delegate
extension HomeVC: MealTitleViewDelegate {
    func mealTitleView(_ mealTitleView: MealTitleView, didPressTag tag: Int, isExpand: Bool) {
        self.mealCellIsExpanded[tag] = isExpand
        self.homeTableView.reloadSections(IndexSet(integer: tag + 2), with: .automatic)
    }
}
