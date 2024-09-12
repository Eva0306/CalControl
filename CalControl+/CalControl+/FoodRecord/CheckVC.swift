//
//  CheckVC.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/11.
//

import UIKit

class CheckVC: UIViewController {
    
    var checkPhoto: UIImage?
    
    private let checkImageView = UIImageView()
    
    lazy var homeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Close", for: .normal)
        btn.addTarget(self, action: #selector(backToHome), for: .touchUpInside)
        return btn
    }()
    
    lazy var reselectButton: UIButton = {
            let btn = UIButton(type: .system)
            btn.setTitle("Reselect", for: .normal)
            btn.addTarget(self, action: #selector(reselectPhoto), for: .touchUpInside)
            return btn
        }()
    
    lazy var recordButton: UIButton = {
            let btn = UIButton(type: .system)
            btn.setTitle("Record", for: .normal)
            // TODO:
            return btn
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        setupView()
    }
    
    private func setupView() {
        checkImageView.contentMode = .scaleAspectFill
        checkImageView.clipsToBounds = true
        checkImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(checkImageView)
        
        NSLayoutConstraint.activate([
            checkImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            checkImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            checkImageView.widthAnchor.constraint(equalToConstant: 300),
            checkImageView.heightAnchor.constraint(equalToConstant: 400)
        ])
        
        if let photo = checkPhoto {
            checkImageView.image = photo
        }
        
        setupButtons()
    }
    
    private func setupButtons() {
        
        let buttonStackView = UIStackView(arrangedSubviews: [homeButton, reselectButton, recordButton])
        buttonStackView.axis = .horizontal
        buttonStackView.alignment = .center
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 20
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(buttonStackView)
        
        NSLayoutConstraint.activate([
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            buttonStackView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func backToHome() {
        
        presentingViewController?.presentingViewController?.dismiss(animated: true, completion: {
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let mainTabBarController = window.rootViewController as? UITabBarController {
                mainTabBarController.selectedIndex = 0
            }
        })
    }
    
    @objc private func reselectPhoto() {
        // 僅關閉 CheckVC，返回上一個視圖控制器
        self.dismiss(animated: true, completion: nil)
    }
}
