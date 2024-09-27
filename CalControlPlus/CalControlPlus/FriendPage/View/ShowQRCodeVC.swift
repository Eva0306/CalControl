//
//  ShowQRCodeVC.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/26.
//

import UIKit
import CoreImage

class ShowQRCodeVC: UIViewController {
    
    let userID = UserProfileViewModel.shared.user.id
    
    private lazy var qrCodeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var userIDLabel: UILabel = {
        let label = UILabel()
        label.text = "我的ID :\n\n\(userID)\n長按以複製"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        
        setupUI()
        generateQRCode()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(copyUserIDToClipboard))
        userIDLabel.addGestureRecognizer(longPressGesture)
    }
    
    private func setupUI() {
        view.addSubview(qrCodeImageView)
        view.addSubview(userIDLabel)
        
        NSLayoutConstraint.activate([
            qrCodeImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60),
            qrCodeImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
            qrCodeImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            qrCodeImageView.heightAnchor.constraint(equalTo: qrCodeImageView.widthAnchor, multiplier: 1.0),
            
            userIDLabel.topAnchor.constraint(equalTo: qrCodeImageView.bottomAnchor, constant: 40),
            userIDLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func generateQRCode() {
        let data = userID.data(using: .ascii)
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return }
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")
        
        if let ciImage = filter.outputImage {
            let transformedImage = ciImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
            let qrCodeImage = UIImage(ciImage: transformedImage)
            
            qrCodeImageView.image = qrCodeImage
        }
    }
    
    // MARK: - Long Press Action
    @objc private func copyUserIDToClipboard() {
        UIPasteboard.general.string = userID
        let alert = UIAlertController(title: "已複製", message: "您的 ID 已複製到剪貼板", preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
}
