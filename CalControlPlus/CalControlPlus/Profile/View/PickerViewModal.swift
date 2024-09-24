//
//  PickerViewModal.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/24.
//

import UIKit

class PickerViewModal: UIView {
    
    var pickerView: UIPickerView = UIPickerView()
    var confirmButton: UIButton = UIButton(type: .system)
    var cancelButton: UIButton = UIButton(type: .system)
    
    var confirmAction: (() -> Void)?
    var cancelAction: (() -> Void)?
    
    let modalHeight: CGFloat = 300
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 20
        
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(pickerView)
        
        confirmButton.setTitle("確認", for: .normal)
        confirmButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        self.addSubview(confirmButton)
        
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        self.addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            confirmButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            confirmButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            
            cancelButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            cancelButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            
            pickerView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            pickerView.topAnchor.constraint(equalTo: confirmButton.bottomAnchor, constant: 20),
            pickerView.widthAnchor.constraint(equalTo: self.widthAnchor),
            pickerView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    @objc private func confirmButtonTapped() {
        confirmAction?()
    }
    
    @objc private func cancelButtonTapped() {
        cancelAction?()
    }
    
    func getHeight() -> CGFloat {
        return modalHeight
    }
}
