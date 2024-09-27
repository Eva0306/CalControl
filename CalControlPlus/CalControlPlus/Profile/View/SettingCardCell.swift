//
//  SettingCardCell.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/23.
//

import UIKit
import FirebaseAuth

class SettingCardCell: BaseCardTableViewCell {
    
    static let identifier = "SettingCardCell"
    
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        innerContentView.addSubview(verticalStackView)
        
        NSLayoutConstraint.activate([
            verticalStackView.leadingAnchor.constraint(equalTo: innerContentView.leadingAnchor, constant: 16),
            verticalStackView.trailingAnchor.constraint(equalTo: innerContentView.trailingAnchor, constant: -16),
            verticalStackView.topAnchor.constraint(equalTo: innerContentView.topAnchor, constant: 16),
            verticalStackView.bottomAnchor.constraint(equalTo: innerContentView.bottomAnchor, constant: -16)
        ])
        
        addRow(leftText: "朋友", rightView: createArrowImageView())
        addRow(leftText: "主題", rightView: createTitleAndArrowStack(title: "淺色主題(預設)"))
        addRow(leftText: "提醒", rightView: createSwitch())
        
        addLogoutButton()
    }
    
    private func addRow(leftText: String, rightView: UIView) {
        let horizontalStackView = UIStackView()
        horizontalStackView.axis = .horizontal
        horizontalStackView.alignment = .center
        horizontalStackView.distribution = .equalSpacing
        horizontalStackView.spacing = 8
        
        let leftLabel = UILabel()
        leftLabel.text = leftText
        leftLabel.font = UIFont.systemFont(ofSize: 16)
        
        horizontalStackView.addArrangedSubview(leftLabel)
        horizontalStackView.addArrangedSubview(rightView)
        
        verticalStackView.addArrangedSubview(horizontalStackView)
    }
    
    private func createArrowImageView() -> UIImageView {
        let arrowImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrowImageView.tintColor = .lightGray
        return arrowImageView
    }
    
    private func createTitleAndArrowStack(title: String) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = .darkGray
        
        let arrowImageView = createArrowImageView()
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, arrowImageView])
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }
    
    private func createSwitch() -> UISwitch {
        let switchControl = UISwitch()
        switchControl.onTintColor = .mainGreen
        return switchControl
    }
    
    private func addLogoutButton() {
        let logoutButton = UIButton(type: .system)
        logoutButton.setTitle("登出", for: .normal)
        logoutButton.setTitleColor(.mainRed, for: .normal)
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        
        verticalStackView.addArrangedSubview(logoutButton)
        
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoutButton.centerXAnchor.constraint(equalTo: verticalStackView.centerXAnchor)
        ])
    }
    
    @objc private func logout() {
        
        let alertController = UIAlertController(title: "登出", message: "您確定要登出嗎？", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "確定", style: .destructive) { _ in
            do {
                try Auth.auth().signOut()
                
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
                   let window = sceneDelegate.window {
                    
                    let signInVC = SignInVC()
                    window.rootViewController = UINavigationController(rootViewController: signInVC)
                    window.makeKeyAndVisible()
                }
                
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError.localizedDescription)
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        
        self.findViewController()?.present(alertController, animated: true, completion: nil)
    }
}
