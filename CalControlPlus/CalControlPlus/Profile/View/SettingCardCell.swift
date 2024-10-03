//
//  SettingCardCell.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/23.
//

import UIKit
import FirebaseAuth
import Lottie

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
        
        addRow(leftText: "淺色 \\ 深色模式", rightView: createSwitchModeAnimation())
        addRow(leftText: "好友", rightView: createArrowImageView())
        addRow(leftText: "隱私權政策", rightView: createArrowImageView())
        addRow(leftText: "回報問題", rightView: createArrowImageView())
        
        addLogoutButton()
        addDeleteAccountButton()
    }
}

// MARK: - Setup Cell
extension SettingCardCell {
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
}

// MARK: - Switch Day Night Mode
extension SettingCardCell {
    private func createSwitchModeAnimation() -> UIView {
        let animationView = LottieAnimationView(name: "toggleDayNightAnimation")
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        
        animationView.animationSpeed = 4.0
        updateAnimationViewForCurrentTheme(animationView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleTheme(_:)))
        animationView.addGestureRecognizer(tapGesture)
        animationView.isUserInteractionEnabled = true
        
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalToConstant: 70),
            animationView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        return animationView
    }
    
    @objc private func toggleTheme(_ sender: UITapGestureRecognizer) {
        guard let animationView = sender.view as? LottieAnimationView else { return }
        
        if traitCollection.userInterfaceStyle == .dark {
            changeTheme(to: .light)
            animationView.play(fromProgress: 0.5, toProgress: 0, loopMode: .playOnce, completion: nil)
        } else {
            changeTheme(to: .dark)
            animationView.play(fromProgress: 0, toProgress: 0.5, loopMode: .playOnce, completion: nil)
        }
    }
    
    private func updateAnimationViewForCurrentTheme(_ animationView: LottieAnimationView) {
        if traitCollection.userInterfaceStyle == .dark {
            animationView.currentProgress = 0.5
        } else {
            animationView.currentProgress = 0
        }
    }
    
    private func changeTheme(to style: UIUserInterfaceStyle) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            for window in windowScene.windows {
                window.overrideUserInterfaceStyle = style
            }
        }
    }
}

// MARK: - Logout and Delete Account
extension SettingCardCell {
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
    
    private func addDeleteAccountButton() {
        let deleteButton = UIButton(type: .system)
        deleteButton.setTitle("刪除帳號", for: .normal)
        deleteButton.setTitleColor(.mainRed, for: .normal)
        deleteButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        deleteButton.addTarget(self, action: #selector(deleteAccount), for: .touchUpInside)
        
        verticalStackView.addArrangedSubview(deleteButton)
        
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            deleteButton.centerXAnchor.constraint(equalTo: verticalStackView.centerXAnchor)
        ])
    }
    
    @objc private func logout() {
        
        let alertController = UIAlertController(title: "登出", message: "您確定要登出嗎？", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "確定", style: .destructive) { _ in
            self.logoutFromFirebase()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        
        self.findViewController()?.present(alertController, animated: true, completion: nil)
    }
    
    @objc private func deleteAccount() {
        
        let alertController = UIAlertController(
            title: "刪除帳號",
            message: "您確定要刪除嗎？\n刪除後可能會丟失所有資料",
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "確定", style: .destructive) { _ in
            FirebaseManager.shared.updateDocument(
                from: .users,
                documentID: UserProfileViewModel.shared.user.id,
                data: ["status": "deleted"]) { success in
                    if success {
                        self.showTemporaryAlert(message: "已刪除帳號")
                        self.logoutFromFirebase()
                    } else {
                        self.showTemporaryAlert(message: "無法刪除帳號")
                    }
                }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        
        self.findViewController()?.present(alertController, animated: true, completion: nil)
    }
    
    private func logoutFromFirebase() {
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
    
    private func showTemporaryAlert(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        self.findViewController()?.present(alertController, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            alertController.dismiss(animated: true, completion: nil)
        }
    }
}
