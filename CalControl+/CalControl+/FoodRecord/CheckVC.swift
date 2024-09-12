//
//  CheckVC.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/11.
//

import UIKit

class CheckVC: UIViewController {
    
    var checkPhoto: UIImage?
    
    private let checkImageView = UIImageView()
    
    lazy var backButton = UIButton()
    
    lazy var retakeButton = UIButton()
    
    lazy var recordButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        setupView()
    }
    
    private func setupView() {
        checkImageView.contentMode = .scaleToFill
        checkImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(checkImageView)
        
        NSLayoutConstraint.activate([
            checkImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            checkImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            checkImageView.widthAnchor.constraint(equalToConstant: 300),
            checkImageView.heightAnchor.constraint(equalToConstant: 400)
        ])
        
        if let photo = checkPhoto {
            checkImageView.image = photo
        }
    }
}
