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
    
    lazy var titleButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("今天", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        btn.addTarget(self, action: #selector(titleButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    lazy var rightButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "chevron.compact.right"), for: .normal)
        btn.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    var homeViewModel: HomeViewModel!
    private var subscriptions = Set<AnyCancellable>()
    
    var mealCellIsExpanded: [Bool] = [false, false, false, false]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeViewModel = HomeViewModel()
        setupView()
        addBindings()
        homeViewModel.requestHealthKitAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        homeViewModel.fetchActiveEnergyBurned(for: globalCurrentDate)
    }
    
    private func setupView() {
        
        view.addSubview(homeTableView)
        
        let tabBarHeight = tabBarController?.tabBar.frame.size.height ?? 0
        
        NSLayoutConstraint.activate([
            homeTableView.topAnchor.constraint(equalTo: view.topAnchor),
            homeTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -tabBarHeight-5),
            homeTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            homeTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        let leftButton = UIButton(type: .system)
        leftButton.setImage(UIImage(systemName: "chevron.compact.left"), for: .normal)
        leftButton.addTarget(self, action: #selector(leftButtonTapped), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [leftButton, titleButton, rightButton])
        stackView.axis = .horizontal
        stackView.spacing = 30
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        
        self.navigationItem.titleView = stackView
    }
    
    private func addBindings() {
        homeViewModel.$foodRecords
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.homeTableView.reloadData()
            }
            .store(in: &subscriptions)
        
        homeViewModel.$currentDate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newDate in
                self?.updateTitleButton(with: newDate)
            }
            .store(in: &subscriptions)
    }
    
    @objc func titleButtonTapped() {
        let alert = UIAlertController(title: "選擇日期", message: nil, preferredStyle: .actionSheet)
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.date = homeViewModel.currentDate
        datePicker.maximumDate = Date()

        datePicker.translatesAutoresizingMaskIntoConstraints = false

        let pickerView = UIViewController()
        pickerView.view.addSubview(datePicker)

        NSLayoutConstraint.activate([
            datePicker.centerXAnchor.constraint(equalTo: pickerView.view.centerXAnchor),
            datePicker.centerYAnchor.constraint(equalTo: pickerView.view.centerYAnchor),
            datePicker.leadingAnchor.constraint(greaterThanOrEqualTo: pickerView.view.leadingAnchor, constant: 16),
            datePicker.trailingAnchor.constraint(lessThanOrEqualTo: pickerView.view.trailingAnchor, constant: -16)
        ])

        let pickerSize = datePicker.sizeThatFits(CGSize.zero)
        pickerView.preferredContentSize = pickerSize
        alert.setValue(pickerView, forKey: "contentViewController")
        
        let selectAction = UIAlertAction(title: "Select", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.homeViewModel.changeDate(to: datePicker.date)
        }
        
        alert.addAction(selectAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = titleButton
            popoverController.sourceRect = titleButton.bounds
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func leftButtonTapped() {
        if let newDate = Calendar.current.date(byAdding: .day, value: -1, to: homeViewModel.currentDate) {
            homeViewModel.changeDate(to: newDate)
        }
    }
    
    @objc func rightButtonTapped() {
        if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: homeViewModel.currentDate) {
            homeViewModel.changeDate(to: newDate)
        }
    }
    
    private func updateTitleButton(with date: Date) {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            titleButton.setTitle("今天", for: .normal)
            rightButton.isEnabled = false
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd"
            let dateString = dateFormatter.string(from: date)
            titleButton.setTitle(dateString, for: .normal)
            rightButton.isEnabled = true
        }
    }
}

// MARK: - TableView DataSource
extension HomeVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 + homeViewModel.mealCategories.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 || section == 1 {
            return 1
        } else {
            return mealCellIsExpanded[section - 2] ? homeViewModel.foodRecordsByCategory[section - 2].count : 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            // swiftlint:disable force_cast line_length
            let cell = tableView.dequeueReusableCell(withIdentifier: DailyAnalysisCell.identifier, for: indexPath) as! DailyAnalysisCell
            // swiftlint:enable force_cast line_length
            cell.configure(with: homeViewModel)
            return cell
        } else if indexPath.section == 1 {
            // swiftlint:disable force_cast line_length
            let cell = tableView.dequeueReusableCell(withIdentifier: WaterRecordCell.identifier, for: indexPath) as! WaterRecordCell
            // swiftlint:enable force_cast line_length
            cell.configure(for: homeViewModel.currentDate)
            return cell
        } else {
            // swiftlint:disable force_cast line_length
            let cell = tableView.dequeueReusableCell(withIdentifier: FoodRecordCell.identifier, for: indexPath) as! FoodRecordCell
            // swiftlint:enable force_cast line_length
            let foodRecord = homeViewModel.foodRecordsByCategory[indexPath.section - 2][indexPath.row]
            cell.configure(with: foodRecord)
            return cell
        }
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
        
        let title = homeViewModel.mealCategories[section - 2]
        headerView.configure(title: title, tag: section - 2, isExpanded: isExpanded)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section > 1 else { return }
        performSegue(withIdentifier: "showFoodDetail", sender: self)
    }
}

// MARK: - Meal Title View Delegate
extension HomeVC: MealTitleViewDelegate {
    func mealTitleView(_ mealTitleView: MealTitleView, didPressTag tag: Int, isExpand: Bool) {
        self.mealCellIsExpanded[tag] = isExpand
        self.homeTableView.reloadSections(IndexSet(integer: tag + 2), with: .automatic)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let sectionIndex = tag + 2
            let rect = self.homeTableView.rect(forSection: sectionIndex)
            let visibleRect = self.homeTableView.visibleRect()
            if !visibleRect.contains(rect) {
                self.homeTableView.scrollRectToVisible(rect, animated: true)
            }
        }
    }
}

// MARK: - Prepare Segue
extension HomeVC {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFoodDetail" {
            if let destinationVC = segue.destination as? FoodDetailVC,
               let indexPath = homeTableView.indexPathForSelectedRow {
                let foodRecord = homeViewModel.foodRecordsByCategory[indexPath.section - 2][indexPath.row]
                destinationVC.foodRecord = foodRecord
            }
        }
    }
}
