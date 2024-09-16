//
//  MealSelectionVC.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/16.
//

import UIKit

class MealSelectionVC: UIViewController {
    
    var onMealSelected: ((Int) -> Void)?
    
    lazy private var closeButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "xmark"), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = .mainGreen
        btn.contentHorizontalAlignment = .center
        btn.contentVerticalAlignment = .center
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(closeVC), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        setupMealSelectionView()
    }
    
    override func viewDidLayoutSubviews() {
        closeButton.layer.cornerRadius = closeButton.frame.width / 2
    }
    
    private func setupMealSelectionView() {
        // MealType - 早餐: 0, 午餐: 1, 晚餐: 2, 點心: 3
        let buttonTitles = ["早餐", "午餐", "晚餐", "點心"]
        let buttonStackView = UIStackView()
        buttonStackView.axis = .horizontal
        buttonStackView.alignment = .center
        buttonStackView.spacing = 20
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        for (index, title) in buttonTitles.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.backgroundColor = .mainGreen
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 10
            button.layer.masksToBounds = true
            
            button.tag = index
            button.addTarget(self, action: #selector(mealButtonTapped(_:)), for: .touchUpInside)
            buttonStackView.addArrangedSubview(button)
            button.widthAnchor.constraint(equalToConstant: 60).isActive = true
            button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        }
        
        view.addSubview(closeButton)
        view.addSubview(buttonStackView)
        
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 50),
            closeButton.heightAnchor.constraint(equalToConstant: 50),
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            closeButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: -20)
        ])
    }
    
    @objc private func mealButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        onMealSelected?(sender.tag)
    }
    
    @objc private func closeVC() {
        dismiss(animated: true)
    }
}
