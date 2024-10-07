//
//  FriendListCell.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/10/3.
//

import UIKit

class FriendListCell: BaseCardTableViewCell {
    
    static let identifier = "friendListCell"
    
    var friend: User?
    
    lazy var avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.crop.circle")
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 25
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Friend name"
        label.font = UIFont.systemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        friend = nil
        nameLabel.text = "Friend name"
        avatarImageView.image = UIImage(systemName: "person.crop.circle")
    }
    
    func configure(with friend: Friend) {
        fetchFriendData(friendID: friend.userID) { [weak self] success in
            guard let self = self else { return }
            if success {
                if let avatarUrl = self.friend?.avatarUrl {
                    avatarImageView.loadImage(with: avatarUrl)
                }
                nameLabel.text = self.friend?.name
            } else {
                print("Error: Unable to fetch friend's data")
            }
        }
    }
    
    private func setupView() {
        innerContentView.addSubview(avatarImageView)
        innerContentView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 50),
            avatarImageView.heightAnchor.constraint(equalToConstant: 50),
            avatarImageView.leadingAnchor.constraint(equalTo: innerContentView.leadingAnchor, constant: 10),
            avatarImageView.topAnchor.constraint(equalTo: innerContentView.topAnchor, constant: 10),
            avatarImageView.bottomAnchor.constraint(equalTo: innerContentView.bottomAnchor, constant: -10),
            
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 20),
            nameLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: innerContentView.trailingAnchor, constant: -10)
        ])
    }
    
    private func fetchFriendData(friendID: String, completion: @escaping (Bool) -> Void) {
        let condition = [FirestoreCondition(field: "id", comparison: .isEqualTo, value: friendID)]
        
        FirebaseManager.shared.getDocuments(
            from: .users,
            where: condition
        ) { [weak self] (users: [User]) in
            guard let self = self else { return }
            
            if let user = users.first {
                let friend = user
                self.friend = friend
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}
