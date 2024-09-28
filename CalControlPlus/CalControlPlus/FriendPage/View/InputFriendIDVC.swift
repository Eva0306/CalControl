//
//  InputFriendIDVC.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/26.
//

import UIKit

class InputFriendIDVC: UIViewController {
    
    var viewModel: FriendViewModel?
    
    private let friendIDTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "請輸入好友ID"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("加入好友", for: .normal)
        button.tintColor = .white
        button.backgroundColor = .mainGreen
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addFriendButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        
        setupView()
    }
    
    private func setupView() {
        view.addSubview(friendIDTextField)
        view.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            friendIDTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            friendIDTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            friendIDTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            friendIDTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            friendIDTextField.heightAnchor.constraint(equalToConstant: 50),
            
            addButton.topAnchor.constraint(equalTo: friendIDTextField.bottomAnchor, constant: 20),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
            addButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func addFriendButtonTapped() {
        guard let friendID = friendIDTextField.text, !friendID.isEmpty else {
            print("請輸入好友ID")
            return
        }
        viewModel?.addFriend(self, with: friendID)
    }
}
