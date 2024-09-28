//
//  InfoActivityVC.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/28.
//

import UIKit

class InfoActivityVC: UIViewController {
    
    private var buttons: [UIButton] = []
    private var selectedActivity: ActivityLevel?
    
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
        for activity in ActivityLevel.allCases {
            let button = UIButton(type: .system)
            button.setTitle(activity.description(), for: .normal)
            button.tag = activity.rawValue
            button.addTarget(self, action: #selector(activityButtonTapped(_:)), for: .touchUpInside)
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
                button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 120).isActive = true
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
    
    @objc private func activityButtonTapped(_ sender: UIButton) {
        if let activityLevel = ActivityLevel(rawValue: sender.tag) {
            selectedActivity = activityLevel
            
            buttons.forEach { $0.backgroundColor = .clear}
            buttons.forEach { $0.tintColor = .mainGreen }
            sender.backgroundColor = .mainGreen
            sender.tintColor = .white
            
            nextButton.isEnabled = true
            nextButton.backgroundColor = .lightGreen
            nextButton.tintColor = .white
        }
    }
    
    @objc private func nextButtonTapped() {
        guard let activityLevel = selectedActivity else { return }
        
        UserInfoCollector.shared.activity = activityLevel
        
        let targetVC = InfoTargetVC()
        self.navigationController?.pushViewController(targetVC, animated: true)
    }
}
