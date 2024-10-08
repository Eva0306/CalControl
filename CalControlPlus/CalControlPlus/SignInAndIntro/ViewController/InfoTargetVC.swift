//
//  InfoTargetVC.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/28.
//

import UIKit
import Lottie

class InfoTargetVC: UIViewController {
    
    private var buttons: [UIButton] = []
    private var selectedTarget: Target?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "您的目標！"
        label.textAlignment = .center
        label.textColor = .darkGreen
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nextButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Next", for: .normal)
        btn.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.isEnabled = false
        btn.backgroundColor = .lightGray
        btn.tintColor = .white
        btn.layer.cornerRadius = 8
        return btn
    }()
    
    var nextPage: (() -> Void)?
    
    private var lottieAnimationView: LottieAnimationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        setupUI()
        setupLottieAnimation()
    }
    
    private func setupUI() {
        let buttonStackView = UIStackView()
        buttonStackView.axis = .vertical
        buttonStackView.alignment = .fill
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 20
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false

        for target in Target.allCases {
            let button = UIButton(type: .system)
            button.setTitle(target.description(), for: .normal)
            button.tag = target.rawValue
            button.addTarget(self, action: #selector(targetButtonTapped(_:)), for: .touchUpInside)
            button.layer.cornerRadius = 8
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.mainGreen.cgColor
            button.tintColor = .mainGreen
            button.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            buttons.append(button)
            buttonStackView.addArrangedSubview(button)
        }
        
        let mainStackView = UIStackView(arrangedSubviews: [titleLabel, buttonStackView, nextButton])
        mainStackView.axis = .vertical
        mainStackView.alignment = .fill
        mainStackView.distribution = .equalSpacing
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(mainStackView)

        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            nextButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupLottieAnimation() {
        lottieAnimationView = LottieAnimationView(name: "ButtonAnimation")
        guard let lottieAnimationView = lottieAnimationView else { return }
        
        lottieAnimationView.translatesAutoresizingMaskIntoConstraints = false
        lottieAnimationView.contentMode = .scaleAspectFill
        lottieAnimationView.loopMode = .loop
        lottieAnimationView.isUserInteractionEnabled = false
        
        nextButton.addSubview(lottieAnimationView)
        nextButton.sendSubviewToBack(lottieAnimationView)
        
        NSLayoutConstraint.activate([
            lottieAnimationView.leadingAnchor.constraint(equalTo: nextButton.leadingAnchor),
            lottieAnimationView.trailingAnchor.constraint(equalTo: nextButton.trailingAnchor),
            lottieAnimationView.topAnchor.constraint(equalTo: nextButton.topAnchor),
            lottieAnimationView.bottomAnchor.constraint(equalTo: nextButton.bottomAnchor)
        ])
        
        lottieAnimationView.stop()
        lottieAnimationView.isHidden = true
    }
    
    @objc private func targetButtonTapped(_ sender: UIButton) {
        if let target = Target(rawValue: sender.tag) {
            selectedTarget = target
            
            buttons.forEach { $0.backgroundColor = .clear }
            buttons.forEach { $0.tintColor = .mainGreen }
            sender.backgroundColor = .mainGreen
            sender.tintColor = .white
            
            nextButton.isEnabled = true
            nextButton.backgroundColor = .clear
            
            lottieAnimationView?.isHidden = false
            lottieAnimationView?.play()
        }
    }
    
    @objc private func nextButtonTapped() {
        guard let target = selectedTarget else { return }
        
        UserInfoCollector.shared.target = target
        
        nextPage?()
    }
}
