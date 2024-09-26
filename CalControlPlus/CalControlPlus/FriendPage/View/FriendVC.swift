//
//  FriendVC.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/18.
//

import UIKit
import Combine

class FriendVC: UIViewController {
    
    private lazy var friendTableView: UITableView = {
        let tv = UITableView()
        tv.dataSource = self
        tv.delegate = self
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(FriendCardCell.self, forCellReuseIdentifier: FriendCardCell.identifier)
        return tv
    }()
    
    var friendViewModel = FriendViewModel()
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        friendViewModel.fetchFriendData()
        addBindings()
    }
    
    private func setupView() {
        
        let addFriendsButton = UIBarButtonItem(
                image: UIImage(systemName: "plus"),
                style: .plain,
                target: self,
                action: #selector(addFriendButtonTapped)
            )
        navigationItem.rightBarButtonItem = addFriendsButton
        
        view.addSubview(friendTableView)
        
        let tabBarHeight = tabBarController?.tabBar.frame.size.height ?? 0
        
        NSLayoutConstraint.activate([
            friendTableView.topAnchor.constraint(equalTo: view.topAnchor),
            friendTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -tabBarHeight-20),
            friendTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            friendTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    @objc private func addFriendButtonTapped() {
        performSegue(withIdentifier: "showAddFriend", sender: self)
    }
    
    private func addBindings() {
        friendViewModel.$friends
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.friendTableView.reloadData()
            }
            .store(in: &subscriptions)
    }
}

// MARK: - TableView DataSource
extension FriendVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendViewModel.friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable force_cast line_length
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendCardCell.identifier, for: indexPath) as! FriendCardCell
        // swiftlint:enable force_cast line_length
        cell.configure(with: friendViewModel.friends[indexPath.row])
        return cell
    }
}

extension FriendVC: UITableViewDelegate {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddFriend" {
            if let destinationVC = segue.destination as? AddFriendVC {
                destinationVC.viewModel = friendViewModel
            }
        }
    }
}
