//
//  InfoGenderVC.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/28.
//

import UIKit

class InfoGenderVC: UIViewController {
    
    private var buttons: [UIButton] = []
    private var selectedGender: Gender?
    
    private lazy var stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 20
        sv.alignment = .fill
        sv.distribution = .equalSpacing
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
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
        for gender in Gender.allCases {
            let button = UIButton(type: .system)
            button.setTitle(gender.description(), for: .normal)
            button.tag = gender.rawValue
            button.addTarget(self, action: #selector(genderButtonTapped(_:)), for: .touchUpInside)
            button.layer.cornerRadius = 8
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.mainGreen.cgColor
            button.tintColor = .mainGreen
            button.translatesAutoresizingMaskIntoConstraints = false
            
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
        
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        
        buttons.forEach {
            $0.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
        
        view.addSubview(nextButton)
        NSLayoutConstraint.activate([
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100)
        ])
    }
    
    @objc private func genderButtonTapped(_ sender: UIButton) {
        if let gender = Gender(rawValue: sender.tag) {
            selectedGender = gender
            
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
        guard let gender = selectedGender else { return }
        
        UserInfoCollector.shared.gender = gender
        
        let birthdayVC = InfoBirthdayVC()
        self.navigationController?.pushViewController(birthdayVC, animated: true)
    }
}
