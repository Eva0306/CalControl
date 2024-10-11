//
//  NutritionImageCell.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/13.
//

import UIKit

class NutritionImageCell: BaseCardTableViewCell {
    
    static let identifier = "NutritionImageCell"
    
    var didChangedPhoto: ((UIImage) -> Void)?
    
    private let foodImageView = UIImageView()
    
    private let colorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightOrg
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var addPhotoButton: UIButton = {
       let btn = UIButton()
        btn.setImage(UIImage(systemName: "camera.circle.fill"), for: .normal)
        btn.alpha = 0.8
        btn.tintColor = .mainGreen
        btn.contentVerticalAlignment = .fill
        btn.contentHorizontalAlignment = .fill
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(addPhoto), for: .touchUpInside)
        return btn
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica Neue", size: 30)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var isImageMode: Bool = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupImageView()
        setupNameView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(image: UIImage?, name: String?) {
        if let image = image {
            isImageMode = true
            foodImageView.image = image
            showImageView()
        } else {
            isImageMode = false
            nameLabel.text = name ?? "Food"
            showNameView()
        }
    }
    
    func configureCell(image: String?, name: String?) {
        if let image = image {
            isImageMode = true
            foodImageView.loadImage(with: image)
            showImageView()
        } else {
            isImageMode = false
            nameLabel.text = name ?? "Food"
            showNameView()
        }
    }
    
    @objc private func addPhoto() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        if let viewController = self.findViewController() {
            viewController.present(imagePicker, animated: true, completion: nil)
        } else {
            debugLog("Error - Could not find view controller.")
        }
    }
    
    private func setupImageView() {
        foodImageView.contentMode = .scaleAspectFit
        foodImageView.translatesAutoresizingMaskIntoConstraints = false
        foodImageView.clipsToBounds = true
        
        innerContentView.addSubview(foodImageView)
        
        NSLayoutConstraint.activate([
            foodImageView.leadingAnchor.constraint(equalTo: innerContentView.leadingAnchor),
            foodImageView.trailingAnchor.constraint(equalTo: innerContentView.trailingAnchor),
            foodImageView.topAnchor.constraint(equalTo: innerContentView.topAnchor),
            foodImageView.bottomAnchor.constraint(equalTo: innerContentView.bottomAnchor),
            foodImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 400)
        ])
    }
    
    private func setupNameView() {
        innerContentView.addSubview(colorView)
        
        NSLayoutConstraint.activate([
            colorView.leadingAnchor.constraint(equalTo: innerContentView.leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: innerContentView.trailingAnchor),
            colorView.topAnchor.constraint(equalTo: innerContentView.topAnchor),
            colorView.bottomAnchor.constraint(equalTo: innerContentView.bottomAnchor),
            colorView.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        colorView.addSubview(nameLabel)
        innerContentView.addSubview(addPhotoButton)
        
        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: colorView.centerXAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: colorView.centerYAnchor),
            
            addPhotoButton.trailingAnchor.constraint(equalTo: innerContentView.trailingAnchor, constant: -10),
            addPhotoButton.bottomAnchor.constraint(equalTo: innerContentView.bottomAnchor, constant: -10),
            addPhotoButton.heightAnchor.constraint(equalToConstant: 50),
            addPhotoButton.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func showImageView() {
        foodImageView.isHidden = false
        colorView.isHidden = true
    }
    
    private func showNameView() {
        foodImageView.isHidden = true
        colorView.isHidden = false
    }
}

extension NutritionImageCell: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let selectedImage = info[.editedImage] as? UIImage {
            colorView.isHidden = true
            foodImageView.isHidden = false
            foodImageView.image = selectedImage
            didChangedPhoto?(selectedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
