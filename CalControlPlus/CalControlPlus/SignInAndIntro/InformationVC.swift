//
//  InformationVC.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/27.
//

import UIKit
import FirebaseFirestore

class InformationVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var userID: String?
    var defaultName: String?
    var email: String?
    
    // MARK: - Properties
    var scrollView: UIScrollView!
    var contentView: UIView!
    
    var nameLabel: UILabel!
    var nameTextField: UITextField!
    
    var avatarLabel: UILabel!
    var avatarImageView: UIImageView!
    
    var genderLabel: UILabel!
    var genderSegmentedControl: UISegmentedControl!
    
    var birthdayLabel: UILabel!
    var birthdayTextField: UITextField!
    
    var heightLabel: UILabel!
    var heightTextField: UITextField!
    
    var weightLabel: UILabel!
    var weightTextField: UITextField!
    
    var activityLabel: UILabel!
    var activitySegmentedControl: UISegmentedControl!
    
    var targetLabel: UILabel!
    var targetSegmentedControl: UISegmentedControl!
    
    var confirmButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        scrollView = UIScrollView()
        contentView = UIView()
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Name Label and TextField
        nameLabel = createLabel(text: "Name")
        nameTextField = createTextField(placeholder: "Name")
        nameTextField.text = defaultName
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(nameTextField)
        
        // Avatar Label and ImageView
        avatarLabel = createLabel(text: "Avatar")
        avatarImageView = UIImageView()
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.image = UIImage(systemName: "person.crop.circle")
        avatarImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectAvatarImage))
        avatarImageView.addGestureRecognizer(tapGesture)
        
        contentView.addSubview(avatarLabel)
        contentView.addSubview(avatarImageView)
        
        // Gender Label and SegmentedControl
        genderLabel = createLabel(text: "Gender")
        genderSegmentedControl = UISegmentedControl(items: ["Male", "Female", "Other"])
        genderSegmentedControl.selectedSegmentIndex = 0
        
        contentView.addSubview(genderLabel)
        contentView.addSubview(genderSegmentedControl)
        
        // Birthday Label and TextField
        birthdayLabel = createLabel(text: "Birthday")
        birthdayTextField = createTextField(placeholder: "Birthday (YYYY-MM-DD)")
        
        contentView.addSubview(birthdayLabel)
        contentView.addSubview(birthdayTextField)
        
        // Height Label and TextField
        heightLabel = createLabel(text: "Height")
        heightTextField = createTextField(placeholder: "Height (cm)")
        
        contentView.addSubview(heightLabel)
        contentView.addSubview(heightTextField)
        
        // Weight Label and TextField
        weightLabel = createLabel(text: "Weight")
        weightTextField = createTextField(placeholder: "Weight (kg)")
        
        contentView.addSubview(weightLabel)
        contentView.addSubview(weightTextField)
        
        // Activity Label and SegmentedControl (0-4)
        activityLabel = createLabel(text: "Activity Level")
        activitySegmentedControl = UISegmentedControl(items: ["0", "1", "2", "3", "4"])
        activitySegmentedControl.selectedSegmentIndex = 0
        
        contentView.addSubview(activityLabel)
        contentView.addSubview(activitySegmentedControl)
        
        // Target Label and SegmentedControl (0-2)
        targetLabel = createLabel(text: "Target")
        targetSegmentedControl = UISegmentedControl(items: ["0", "1", "2"])
        targetSegmentedControl.selectedSegmentIndex = 0
        
        contentView.addSubview(targetLabel)
        contentView.addSubview(targetSegmentedControl)
        
        // Confirm Button
        confirmButton = UIButton(type: .system)
        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        contentView.addSubview(confirmButton)
        
        // Layout UI Elements
        layoutUI()
    }
    
    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }
    
    private func createTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        return textField
    }
    
    private func layoutUI() {
        // Enable Auto Layout for all UI elements
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        genderLabel.translatesAutoresizingMaskIntoConstraints = false
        genderSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        birthdayLabel.translatesAutoresizingMaskIntoConstraints = false
        birthdayTextField.translatesAutoresizingMaskIntoConstraints = false
        heightLabel.translatesAutoresizingMaskIntoConstraints = false
        heightTextField.translatesAutoresizingMaskIntoConstraints = false
        weightLabel.translatesAutoresizingMaskIntoConstraints = false
        weightTextField.translatesAutoresizingMaskIntoConstraints = false
        activityLabel.translatesAutoresizingMaskIntoConstraints = false
        activitySegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        targetLabel.translatesAutoresizingMaskIntoConstraints = false
        targetSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            avatarLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            avatarLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            avatarImageView.topAnchor.constraint(equalTo: avatarLabel.bottomAnchor, constant: 8),
            avatarImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 100),
            avatarImageView.heightAnchor.constraint(equalToConstant: 100),
            
            genderLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 20),
            genderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            genderSegmentedControl.topAnchor.constraint(equalTo: genderLabel.bottomAnchor, constant: 8),
            genderSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            genderSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            birthdayLabel.topAnchor.constraint(equalTo: genderSegmentedControl.bottomAnchor, constant: 20),
            birthdayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            birthdayTextField.topAnchor.constraint(equalTo: birthdayLabel.bottomAnchor, constant: 8),
            birthdayTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            birthdayTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            heightLabel.topAnchor.constraint(equalTo: birthdayTextField.bottomAnchor, constant: 20),
            heightLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            heightTextField.topAnchor.constraint(equalTo: heightLabel.bottomAnchor, constant: 8),
            heightTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            heightTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            weightLabel.topAnchor.constraint(equalTo: heightTextField.bottomAnchor, constant: 20),
            weightLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            weightTextField.topAnchor.constraint(equalTo: weightLabel.bottomAnchor, constant: 8),
            weightTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            weightTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            activityLabel.topAnchor.constraint(equalTo: weightTextField.bottomAnchor, constant: 20),
            activityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            activitySegmentedControl.topAnchor.constraint(equalTo: activityLabel.bottomAnchor, constant: 8),
            activitySegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            activitySegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            targetLabel.topAnchor.constraint(equalTo: activitySegmentedControl.bottomAnchor, constant: 20),
            targetLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            targetSegmentedControl.topAnchor.constraint(equalTo: targetLabel.bottomAnchor, constant: 8),
            targetSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            targetSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            confirmButton.topAnchor.constraint(equalTo: targetSegmentedControl.bottomAnchor, constant: 20),
            confirmButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            confirmButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20) // 讓 contentView 滑到底
        ])
    }
    
    // MARK: - Actions
    @objc private func selectAvatarImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            avatarImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
}

extension InformationVC {
    @objc private func confirmButtonTapped() {
        guard let userID = userID,
              let name = nameTextField.text,
              !name.isEmpty,
              let birthday = birthdayTextField.text,
              !birthday.isEmpty,
              let heightText = heightTextField.text,
              let height = Double(heightText),
              let weightText = weightTextField.text,
              let weight = Double(weightText) else {
            print("Please fill in all required fields.")
            return
        }
        
        let genderIndex = genderSegmentedControl.selectedSegmentIndex
        let activityIndex = activitySegmentedControl.selectedSegmentIndex
        let targetIndex = targetSegmentedControl.selectedSegmentIndex
        
        guard let gender = Gender(rawValue: genderIndex) else { return }
        guard let activity = ActivityLevel(rawValue: activityIndex) else { return }
        guard let target = Target(rawValue: targetIndex) else { return }
        
        var avatarData: String?
        if let avatarImage = avatarImageView.image {
            FirebaseManager.shared.uploadImage(image: avatarImage) { url in
                
                avatarData = url?.absoluteString
                let userData: User = User(
                    id: userID,
                    createdTime: Timestamp(date: Date()),
                    email: self.email,
                    name: name,
                    avatarUrl: avatarData,
                    gender: gender,
                    birthday: birthday,
                    height: height,
                    weightRecord: [WeightRecord(date: Timestamp(date: Date()), weight: weight)],
                    activity: activity,
                    target: target,
                    totalNutrition: self.generateBlankNutriData()
                )
                
                let userRef = FirebaseManager.shared.newDocument(
                    of: .users,
                    documentID: userID
                )
                FirebaseManager.shared.setData(userData, at: userRef, merge: false)
                
                UserProfileViewModel.shared = UserProfileViewModel(user: userData)
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
                   let window = sceneDelegate.window {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    // swiftlint:disable force_cast line_length
                    let tabBarController = storyboard.instantiateInitialViewController() as! MainTabBarController
                    // swiftlint:enable force_cast line_length
                    window.rootViewController = tabBarController
                    window.makeKeyAndVisible()
                }
            }
        }
    }
    
    func generateBlankNutriData() -> [TotalNutrition] {
        let currentDate = Calendar.current.startOfDay(for: Date())
        var nutritionArray: [TotalNutrition] = []
        for i in 0..<7 {
            if let previousDate = Calendar.current.date(byAdding: .day, value: -i, to: currentDate) {
                let nutrition = TotalNutrition(
                    date: Timestamp(date: previousDate),
                    totalCalories: 0,
                    totalCarbs: 0,
                    totalProtein: 0,
                    totalFats: 0
                )
                nutritionArray.insert(nutrition, at: 0)
            }
        }
        return nutritionArray
    }
}
