//
//  FriendListVC.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/10/3.
//

import UIKit
import Combine

class FriendListVC: UIViewController {
    
    private lazy var friendListTableView: UITableView = {
        let tv = UITableView()
        tv.dataSource = self
        tv.delegate = self
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(FriendListCell.self, forCellReuseIdentifier: FriendListCell.identifier)
        return tv
    }()
    
    private lazy var hintLabel: UILabel = {
        let label = UILabel()
        label.text = "目前尚無好友\n\n至好友頁新增好友吧！"
        label.font = .systemFont(ofSize: 28, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .mainGreen.withAlphaComponent(0.6)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var friendViewModel = FriendViewModel()
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        
        setupView()
        addBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let mainTabBarController = self.tabBarController as? MainTabBarController {
            mainTabBarController.plusButtonAnimationView.isHidden = true
        }
        self.tabBarController?.tabBar.isHidden = true
        friendViewModel.fetchFriendData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let mainTabBarController = self.tabBarController as? MainTabBarController {
            mainTabBarController.plusButtonAnimationView.isHidden = false
        }
        self.tabBarController?.tabBar.isHidden = false
    }
    
    private func setupView() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "封鎖名單",
            style: .plain,
            target: self,
            action: #selector(goToBlockList)
        )
        
        let titleLabel = UILabel()
        titleLabel.text = "好友名單"
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 28)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        view.addSubview(friendListTableView)
        view.addSubview(hintLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            hintLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hintLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            friendListTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            friendListTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            friendListTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            friendListTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func addBindings() {
        friendViewModel.$friends
            .receive(on: DispatchQueue.main)
            .sink { [weak self] friends in
                self?.friendListTableView.reloadData()
                self?.friendListTableView.isHidden = friends.isEmpty
                self?.hintLabel.isHidden = !friends.isEmpty
            }
            .store(in: &subscriptions)
    }
    
    @objc private func goToBlockList() {
        let blockListVC = BlockListVC()
        blockListVC.friendViewModel = self.friendViewModel
        self.navigationController?.pushViewController(blockListVC, animated: true)
    }
}

// MARK: - TableView DataSource
extension FriendListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        friendViewModel.friends.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < friendViewModel.friends.count {
            let cell: FriendListCell = tableView.dequeueReusableCell(
                withIdentifier: FriendListCell.identifier, for: indexPath
            )
            let friend = friendViewModel.friends[indexPath.row]
            cell.configure(with: friend)
            return cell
        } else {
            let cell = UITableViewCell()
            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            cell.textLabel?.text = "向左滑可封鎖或刪除好友"
            cell.textLabel?.textColor = .gray
            cell.textLabel?.textAlignment = .center
            return cell
        }
    }
}

// MARK: - Delete or Block Friend
extension FriendListVC: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let friend = friendViewModel.friends[indexPath.row]
        
        let blockAction = UIContextualAction(
            style: .normal, title: "封鎖"
        ) { [weak self] (_, _, completionHandler) in
            self?.showBlockFriendAlert(for: friend)
            completionHandler(true)
        }
        blockAction.backgroundColor = .systemOrange
        
        let deleteAction = UIContextualAction(
            style: .destructive, title: "刪除"
        ) { [weak self] (_, _, completionHandler) in
            self?.showDeleteFriendAlert(for: friend)
            completionHandler(true)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, blockAction])
        return configuration
    }
    
    private func showBlockFriendAlert(for friend: Friend) {
        HapticFeedbackHelper.generateNotificationFeedback(type: .warning)
        
        let alertController = UIAlertController(
            title: "封鎖好友",
            message: "封鎖後會從好友雙方名單中移除\n並需要解除封鎖才能重新加入",
            preferredStyle: .alert
        )
        let confirmAction = UIAlertAction(title: "確認", style: .default) { [weak self] _ in
            self?.blockFriend(friend)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func showDeleteFriendAlert(for friend: Friend) {
        HapticFeedbackHelper.generateNotificationFeedback(type: .warning)
        
        let alertController = UIAlertController(
            title: "刪除好友",
            message: "刪除好友僅會從個人好友名單中刪除",
            preferredStyle: .alert
        )
        let confirmAction = UIAlertAction(title: "確認", style: .default) { [weak self] _ in
            self?.deleteFriend(friend)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func blockFriend(_ friend: Friend) {
        friendViewModel.updateFriendStatus(friendID: friend.userID, status: "blocked") { success in
            if success {
                debugLog("Successfully blocked friend locally.")
                self.friendViewModel.updateFriendStatusFromFriend(
                    friendID: friend.userID,
                    status: "blocked"
                ) { success in
                    if success {
                        debugLog("Successfully blocked friend remotely.")
                    }
                }
            }
        }
    }
    
    private func deleteFriend(_ friend: Friend) {
        friendViewModel.removeFriend(friendID: friend.userID) { [weak self] in
            debugLog("Successfully deleted friend.")
        }
    }
}
