//
//  InputViewController.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/10/5.
//

import UIKit

class InputViewController: UIViewController {
    
    let portionTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "份量"
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "食物種類"
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        preferredContentSize = CGSize(width: 270, height: 100)
        KeyboardManager.shared.setupKeyboardManager(for: self, textFields: [portionTextField, nameTextField])
    }
    
    private func setupView() {
        view.addSubview(portionTextField)
        view.addSubview(nameTextField)
        
        NSLayoutConstraint.activate([
            portionTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            portionTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            portionTextField.widthAnchor.constraint(equalToConstant: 270),
            portionTextField.heightAnchor.constraint(equalToConstant: 40),
            
            nameTextField.topAnchor.constraint(equalTo: portionTextField.bottomAnchor, constant: 16),
            nameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameTextField.widthAnchor.constraint(equalToConstant: 270),
            nameTextField.heightAnchor.constraint(equalToConstant: 40),
            nameTextField.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
        ])
    }
}
