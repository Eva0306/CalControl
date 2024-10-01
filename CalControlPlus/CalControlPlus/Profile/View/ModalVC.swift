//
//  ModalVC.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/24.
//

import UIKit

class ModalVC: UIViewController {
    
    var pickerViewModal: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupModalView()
    }
    
    private func setupModalView() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        if let pickerViewModal = pickerViewModal {
            self.view.addSubview(pickerViewModal)
            
            pickerViewModal.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                pickerViewModal.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                pickerViewModal.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                pickerViewModal.heightAnchor.constraint(equalToConstant: 300),
                pickerViewModal.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 300)
            ])
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissModal))
        view.addGestureRecognizer(tapGesture)
    }
    
    func presentModal() {
        UIView.animate(withDuration: 0.3, animations: {
            self.pickerViewModal?.transform = CGAffineTransform(translationX: 0, y: -300)
        })
    }
    
    @objc func dismissModal() {
        UIView.animate(withDuration: 0.3, animations: {
            self.pickerViewModal?.transform = .identity
        }, completion: { _ in
            self.dismiss(animated: false, completion: nil)
        })
    }
}
