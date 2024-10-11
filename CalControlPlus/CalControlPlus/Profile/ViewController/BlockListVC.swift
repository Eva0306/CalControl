//
//  BlockListVC.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/10/4.
//

import UIKit
import Combine

class BlockListVC: UIViewController {
    
    private lazy var blockFriendsTableView: UITableView = {
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
        label.text = "目前無封鎖好友"
        label.font = .systemFont(ofSize: 28, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .mainGreen.withAlphaComponent(0.6)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var friendViewModel: FriendViewModel!
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
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let mainTabBarController = self.tabBarController as? MainTabBarController {
            mainTabBarController.plusButtonAnimationView.isHidden = false
        }
        self.tabBarController?.tabBar.isHidden = false
    }
    
    private func setupView() {
        let titleLabel = UILabel()
        titleLabel.text = "封鎖名單"
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 28)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        view.addSubview(blockFriendsTableView)
        view.addSubview(hintLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            hintLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hintLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            blockFriendsTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            blockFriendsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            blockFriendsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blockFriendsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func addBindings() {
        friendViewModel.$blockFriends
            .receive(on: DispatchQueue.main)
            .sink { [weak self] blockFriends in
                self?.blockFriendsTableView.reloadData()
                self?.blockFriendsTableView.isHidden = blockFriends.isEmpty
                self?.hintLabel.isHidden = !blockFriends.isEmpty
            }
            .store(in: &subscriptions)
    }
}

// MARK: - TableView DataSource
extension BlockListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        friendViewModel.blockFriends.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < friendViewModel.blockFriends.count {
            // swiftlint:disable force_cast line_length
            let cell = tableView.dequeueReusableCell(withIdentifier: FriendListCell.identifier, for: indexPath) as! FriendListCell
            // swiftlint:enable force_cast line_length
            let friend = friendViewModel.blockFriends[indexPath.row]
            cell.configure(with: friend)
            return cell
        } else {
            let cell = UITableViewCell()
            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = "向左滑可解除封鎖好友\n解除後需重新加入好友"
            cell.textLabel?.textColor = .gray
            cell.textLabel?.textAlignment = .center
            return cell
        }
    }
}

// MARK: - Delete or Block Friend
extension BlockListVC: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let friend = friendViewModel.blockFriends[indexPath.row]
        
        let unblockAction = UIContextualAction(
            style: .normal, title: "解除封鎖"
        ) { [weak self] (_, _, completionHandler) in
            self?.showUnblockFriendAlert(for: friend)
            completionHandler(true)
        }
        unblockAction.backgroundColor = .systemOrange
        
        let configuration = UISwipeActionsConfiguration(actions: [unblockAction])
        return configuration
    }
    
    private func showUnblockFriendAlert(for friend: Friend) {
        HapticFeedbackHelper.generateNotificationFeedback(type: .warning)
        
        let alertController = UIAlertController(
            title: "解除封鎖好友",
            message: "解除封鎖後若需重新成為好友\n需重新加入好友",
            preferredStyle: .alert
        )
        let confirmAction = UIAlertAction(title: "確認", style: .default) { [weak self] _ in
            self?.deleteFriendBothSide(friend)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func deleteFriendBothSide(_ friend: Friend) {
        friendViewModel.removeFriend(friendID: friend.userID) { [weak self] in
            
            debugLog("Successfully deleted friend from current user.")
            
            self?.friendViewModel.removeCurrentUserFromFriend(friendID: friend.userID) { success in
                if success {
                    debugLog("Successfully deleted current user from friend's list.")
                } else {
                    debugLog("Failed to delete current user from friend's list.")
                }
            }
        }
    }
}
