//
//  InfoHeightVC.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/28.
//

import UIKit

class InfoHeightVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    private let heightRange = Array(100...250)
    private lazy var heightPickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private lazy var nextButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Next", for: .normal)
        btn.backgroundColor = .lightGreen
        btn.tintColor = .white
        btn.layer.cornerRadius = 8
        btn.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private var selectedHeight: Int = 160

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        
        setupUI()
    }
    
    private func setupUI() {
        heightPickerView.selectRow(selectedHeight - 100, inComponent: 0, animated: true)
        
        view.addSubview(heightPickerView)
        view.addSubview(nextButton)
        
        NSLayoutConstraint.activate([
            heightPickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            heightPickerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100)
        ])
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return heightRange.count
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(heightRange[row]) cm"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedHeight = heightRange[row]
    }
    
    @objc private func nextButtonTapped() {
        UserInfoCollector.shared.height = Double(selectedHeight)
        
        let weightVC = InfoWeightVC()
        self.navigationController?.pushViewController(weightVC, animated: true)
    }
}
