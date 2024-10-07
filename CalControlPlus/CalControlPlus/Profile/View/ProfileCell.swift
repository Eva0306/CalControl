//
//  ProfileCell.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/23.
//

import UIKit

class ProfileCell: UITableViewCell {
    
    static let identifier = "ProfileCell"
    
    lazy var avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.crop.circle")
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 60
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(changeAvatarImage))
        iv.addGestureRecognizer(tapGesture)
        return iv
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "User"
        label.font = UIFont.systemFont(ofSize: 32)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = .clear
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func changeAvatarImage() {
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
    
    private func setupView() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        
        if let avatarUrl = UserProfileViewModel.shared.user.avatarUrl {
            avatarImageView.loadImage(with: avatarUrl)
        }
        nameLabel.text = UserProfileViewModel.shared.user.name
        
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 120),
            avatarImageView.heightAnchor.constraint(equalToConstant: 120),
            avatarImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 15),
            nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
}

extension ProfileCell: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.editedImage] as? UIImage {
            avatarImageView.image = selectedImage
            FirebaseManager.shared.uploadImage(
                image: selectedImage,
                folder: .UserAvatarImages
            ) { [weak self] url in
                guard self != nil else { return }
                if let url = url {
                    FirebaseManager.shared.updateDocument(
                        from: .users,
                        documentID: UserProfileViewModel.shared.user.id,
                        data: ["avatarUrl": url.absoluteString]) { result in
                            if result == true {
                                debugLog("Successed saving image to firebase")
                            } else {
                                debugLog("Failed saving image to firebase")
                            }
                        }
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
