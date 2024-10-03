//
//  InfoNameVC.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/28.
//

import UIKit
import Lottie

class InfoNameVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "輸入您的姓名及上傳大頭照"
        label.textColor = .darkGreen
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.borderStyle = .roundedRect
        tf.delegate = self
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(systemName: "person.crop.circle")
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let plusImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "plus.circle.fill"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .lightGreen
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var nextButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Next", for: .normal)
        btn.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.isEnabled = false
        btn.backgroundColor = .lightGray
        btn.tintColor = .white
        btn.layer.cornerRadius = 8
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
    }
    
    private func setupUI() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectAvatarImage))
        avatarImageView.addGestureRecognizer(tapGesture)
        
        let leftPaddingView = UIView()
        leftPaddingView.backgroundColor = .clear
        leftPaddingView.translatesAutoresizingMaskIntoConstraints = false
        let rightPaddingView = UIView()
        rightPaddingView.backgroundColor = .clear
        rightPaddingView.translatesAutoresizingMaskIntoConstraints = false

        let avatarContainer = UIStackView(arrangedSubviews: [leftPaddingView, avatarImageView, rightPaddingView])
        avatarContainer.axis = .horizontal
        avatarContainer.spacing = 0
        avatarContainer.distribution = .fill

        NSLayoutConstraint.activate([
            leftPaddingView.widthAnchor.constraint(equalToConstant: 30),
            rightPaddingView.widthAnchor.constraint(equalToConstant: 30)
        ])
        
        let mainStackView = UIStackView(arrangedSubviews: [titleLabel, avatarContainer, nameTextField])
        mainStackView.axis = .vertical
        mainStackView.spacing = 40
        mainStackView.alignment = .fill
        mainStackView.distribution = .fill
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(mainStackView)
        view.addSubview(nextButton)
        avatarImageView.addSubview(plusImageView)
        
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            mainStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            
            avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor),
            nameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            plusImageView.heightAnchor.constraint(equalToConstant: 70),
            plusImageView.widthAnchor.constraint(equalToConstant: 70),
            plusImageView.trailingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: -20),
            plusImageView.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: -20),
            
            nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            nextButton.heightAnchor.constraint(equalToConstant: 50)
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
        
        lottieAnimationView.stop()
        lottieAnimationView.isHidden = true
    }
    
    @objc private func selectAvatarImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let selectedImage = info[.originalImage] as? UIImage {
            avatarImageView.image = selectedImage
            UserInfoCollector.shared.avatarImage = avatarImageView.image
        }
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Check User Input
extension InfoNameVC {
    @objc private func nextButtonTapped() {
        guard let name = nameTextField.text,
              !name.isEmpty,
              isValidName(name) else {
            showAlert(title: "請確認輸入", message: "名字不能包含空白或符號")
            return
        }
        
        UserInfoCollector.shared.name = name
        
        nextPage?()
    }
    
    private func isValidName(_ name: String) -> Bool {
        let nameRegex = "^[a-zA-Z0-9\\u4e00-\\u9fa5]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        return predicate.evaluate(with: name)
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UITextFieldDelegate
extension InfoNameVC: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let currentText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        nextButton.isEnabled = !currentText.trimmingCharacters(in: .whitespaces).isEmpty
        
        if nextButton.isEnabled {
            nextButton.backgroundColor = .clear
            // 播放動畫
            lottieAnimationView?.isHidden = false
            lottieAnimationView?.play()
        } else {
            nextButton.backgroundColor = .lightGray
            // 停止動畫，並隱藏
            lottieAnimationView?.stop()
            lottieAnimationView?.isHidden = true
        }
        
        return true
    }
}