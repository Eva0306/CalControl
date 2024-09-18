//
//  HomeVC.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/11.
//

import UIKit

class HomeVC: UIViewController {
    
    private lazy var homeTableView: UITableView = {
        let tv = UITableView()
        tv.dataSource = self
        // tv.delegate = self
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(WaterRecordCell.self, forCellReuseIdentifier: WaterRecordCell.identifier)
        tv.register(DailyAnalysisCell.self, forCellReuseIdentifier: DailyAnalysisCell.identifier)
        return tv
    }()
    
    var currentDate = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(resource: .background)
        
        setupView()
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
}

// MARK: - TableView DataSource
extension HomeVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
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
        }
        return UITableViewCell()
    }
}
