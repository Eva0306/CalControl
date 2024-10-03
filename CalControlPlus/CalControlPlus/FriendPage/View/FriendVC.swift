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
    
    private lazy var friendImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(systemName: "person.2")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var hintLabel: UILabel = {
        let label = UILabel()
        label.text = "目前尚無好友\n\n點擊右上角 + 新增好友吧！"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .mainGreen
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var friendViewModel = FriendViewModel()
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        friendViewModel.fetchFriendData()
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
        view.addSubview(friendImageView)
        view.addSubview(hintLabel)
        
        let tabBarHeight = tabBarController?.tabBar.frame.size.height ?? 0
        
        NSLayoutConstraint.activate([
            friendImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            friendImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            friendImageView.widthAnchor.constraint(equalToConstant: 100),
            friendImageView.heightAnchor.constraint(equalToConstant: 100),
            
            hintLabel.topAnchor.constraint(equalTo: friendImageView.bottomAnchor, constant: 40),
            hintLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hintLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            hintLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
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
            .sink { [weak self] friends in
                self?.friendTableView.reloadData()
                self?.friendImageView.isHidden = !friends.isEmpty
                self?.hintLabel.isHidden = !friends.isEmpty
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
        cell.configure(with: friendViewModel.friends[indexPath.row], viewModel: friendViewModel)
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
