//
//  InfoWeightVC.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/28.
//

import UIKit
import Lottie

class InfoWeightVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    private let weightIntegerRange = Array(30...200)
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "您的體重是..."
        label.textAlignment = .center
        label.textColor = .darkGreen
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let weightDecimalRange = Array(0...9)
    private lazy var weightPickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
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
    
    private var selectedInteger: Int = 60
    private var selectedDecimal: Int = 0
    
    var nextPage: (() -> Void)?
    
    private var lottieAnimationView: LottieAnimationView?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        
        setupUI()
        setupLottieAnimation()
    }
    
    private func setupUI() {
        weightPickerView.selectRow(selectedInteger - 30, inComponent: 0, animated: true)
        weightPickerView.selectRow(selectedDecimal, inComponent: 1, animated: true)
        
        view.addSubview(weightPickerView)
        view.addSubview(titleLabel)
        view.addSubview(nextButton)
        
        NSLayoutConstraint.activate([
            weightPickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            weightPickerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
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
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return weightIntegerRange.count
        } else {
            return weightDecimalRange.count
        }
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return "\(weightIntegerRange[row])"
        } else {
            return ".\(weightDecimalRange[row])"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            selectedInteger = weightIntegerRange[row]
        } else {
            selectedDecimal = weightDecimalRange[row]
        }
    }
    
    @objc private func nextButtonTapped() {
        let weight = Double(selectedInteger) + Double(selectedDecimal) / 10.0
        UserInfoCollector.shared.weight = weight
        
        nextPage?()
    }
}
