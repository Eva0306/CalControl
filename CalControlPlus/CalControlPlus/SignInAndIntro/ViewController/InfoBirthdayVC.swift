//
//  InfoBirthdayVC.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/28.
//

import UIKit
import Lottie

class InfoBirthdayVC: UIViewController {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "您的生日是..."
        label.textAlignment = .center
        label.textColor = .darkGreen
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var birthdayDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    private lazy var nextButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Next", for: .normal)
        btn.backgroundColor = .clear
        btn.tintColor = .white
        btn.layer.cornerRadius = 8
        btn.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
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
        view.addSubview(birthdayDatePicker)
        view.addSubview(titleLabel)
        view.addSubview(nextButton)
        
        NSLayoutConstraint.activate([
            birthdayDatePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            birthdayDatePicker.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
        
        lottieAnimationView.play()
    }
    
    @objc private func nextButtonTapped() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let birthdayString = dateFormatter.string(from: birthdayDatePicker.date)
        
        UserInfoCollector.shared.birthday = birthdayString
        
        nextPage?()
    }
}
