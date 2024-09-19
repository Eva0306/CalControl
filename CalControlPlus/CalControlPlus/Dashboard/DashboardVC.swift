//
//  DashboardVC.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/11.
//

import UIKit

class DashboardVC: UIViewController {
    
    private lazy var DashboardTableView: UITableView = {
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
    
//    var currentDate = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(resource: .background)
        
        setupView()
    }
    
    private func setupView() {
        
        view.addSubview(DashboardTableView)
        
        NSLayoutConstraint.activate([
            DashboardTableView.topAnchor.constraint(equalTo: view.topAnchor),
            DashboardTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            DashboardTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            DashboardTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

// MARK: - TableView DataSource
extension DashboardVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.item == 0 {
            // swiftlint:disable force_cast
            let cell = tableView.dequeueReusableCell(withIdentifier: WeeklyCalAnalysisCell.identifier, for: indexPath) as! WeeklyCalAnalysisCell
            // swiftlint:enable force_cast
            cell.configure()
            return cell
        } else if indexPath.item == 1 {
            // swiftlint:disable force_cast
            let cell = tableView.dequeueReusableCell(withIdentifier: WeeklyNutriAnalysisCell.identifier, for: indexPath) as! WeeklyNutriAnalysisCell
            // swiftlint:enable force_cast
            cell.configure()
            return cell
        }
        return UITableViewCell()
    }
}

