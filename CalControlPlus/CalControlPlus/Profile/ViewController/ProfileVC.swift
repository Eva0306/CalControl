//
//  ProfileVC.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/18.
//

import UIKit

class ProfileVC: UIViewController {
    
    private lazy var profileTableView: UITableView = {
        let tv = UITableView()
        tv.dataSource = self
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(ProfileCell.self, forCellReuseIdentifier: ProfileCell.identifier)
        tv.register(UserBasicCardCell.self, forCellReuseIdentifier: UserBasicCardCell.identifier)
        tv.register(SettingCardCell.self, forCellReuseIdentifier: SettingCardCell.identifier)
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        view.addSubview(profileTableView)
        
        let tabBarHeight = tabBarController?.tabBar.frame.size.height ?? 0
        
        NSLayoutConstraint.activate([
            profileTableView.topAnchor.constraint(equalTo: view.topAnchor),
            profileTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -tabBarHeight),
            profileTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

extension ProfileVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell: ProfileCell = tableView.dequeueReusableCell(
                withIdentifier: ProfileCell.identifier, for: indexPath
            )
            return cell
        } else if indexPath.row == 1 {
            let cell: UserBasicCardCell = tableView.dequeueReusableCell(
                withIdentifier: UserBasicCardCell.identifier, for: indexPath
            )
            return cell
        } else {
            let cell: SettingCardCell = tableView.dequeueReusableCell(
                withIdentifier: SettingCardCell.identifier, for: indexPath
            )
            return cell
        }
    }
}
