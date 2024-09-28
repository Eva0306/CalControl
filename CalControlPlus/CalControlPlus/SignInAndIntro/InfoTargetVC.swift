//
//  InfoTargetVC.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/28.
//

import UIKit

class InfoTargetVC: UIViewController {
    
    private var buttons: [UIButton] = []
    private var selectedTarget: Target?
    
    private lazy var nextButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Next", for: .normal)
        btn.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.isEnabled = false
        btn.backgroundColor = .lightGray
        btn.layer.cornerRadius = 8
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        setupUI()
    }
    
    private func setupUI() {
        for target in Target.allCases {
            let button = UIButton(type: .system)
            button.setTitle(target.description(), for: .normal)
            button.tag = target.rawValue
            button.addTarget(self, action: #selector(targetButtonTapped(_:)), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.layer.cornerRadius = 8
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.mainGreen.cgColor
            button.tintColor = .mainGreen
            
            buttons.append(button)
            view.addSubview(button)
        }
        
        for (index, button) in buttons.enumerated() {
            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
                button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
                button.heightAnchor.constraint(equalToConstant: 50)
            ])
            
            if index == 0 {
                button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 200).isActive = true
            } else {
                button.topAnchor.constraint(equalTo: buttons[index - 1].bottomAnchor, constant: 20).isActive = true
            }
        }
        
        view.addSubview(nextButton)
        NSLayoutConstraint.activate([
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100)
        ])
    }
    
    @objc private func targetButtonTapped(_ sender: UIButton) {
        if let target = Target(rawValue: sender.tag) {
            selectedTarget = target
            
            buttons.forEach { $0.backgroundColor = .clear }
            buttons.forEach { $0.tintColor = .mainGreen }
            sender.backgroundColor = .mainGreen
            sender.tintColor = .white
            
            nextButton.isEnabled = true
            nextButton.backgroundColor = .lightGreen
            nextButton.tintColor = .white
        }
    }
    
    @objc private func nextButtonTapped() {
        guard let target = selectedTarget else { return }
        
        UserInfoCollector.shared.target = target
        
        let startVC = InfoStartVC()
        self.navigationController?.pushViewController(startVC, animated: true)
    }
}
