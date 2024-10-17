//
//  TextVC.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/11.
//

import UIKit

class TextVC: UIViewController {
    
    private lazy var navigationBar: UINavigationBar = {
        let navBar = UINavigationBar()
        navBar.isTranslucent = true
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.backgroundColor = .clear
        navBar.translatesAutoresizingMaskIntoConstraints = false
        return navBar
    }()
    
    private lazy var closeButton: UIBarButtonItem = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "xmark"), for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.contentHorizontalAlignment = .fill
        btn.contentVerticalAlignment = .fill
        btn.tintColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return .white
            default:
                return .darkGray
            }
        }
        btn.addTarget(self, action: #selector(closeVC), for: .touchUpInside)
        return UIBarButtonItem(customView: btn)
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "輸入食物"
        label.textColor = .darkGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var storedFoodButton: UIBarButtonItem = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "takeoutbag.and.cup.and.straw"), for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.contentHorizontalAlignment = .fill
        btn.contentVerticalAlignment = .fill
        btn.tintColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return .white
            default:
                return .darkGray
            }
        }
        btn.addTarget(self, action: #selector(storedFoodTapped), for: .touchUpInside)
        return UIBarButtonItem(customView: btn)
    }()
    
    private lazy var portionTextField: UITextField = {
        let tf = UITextField()
        tf.delegate = self
        tf.backgroundColor = .cellBackground
        tf.layer.cornerRadius = 10
        tf.text = "一個"
        tf.placeholder = "輸入份量"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private lazy var foodTextField: UITextField = {
        let tf = UITextField()
        tf.delegate = self
        tf.backgroundColor = .cellBackground
        tf.layer.cornerRadius = 10
        tf.placeholder = "輸入食物種類"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    lazy var addButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("新增", for: .normal)
        btn.setTitleColor(.lightGray, for: .normal)
        btn.backgroundColor = .mainGreen.withAlphaComponent(0.6)
        btn.layer.cornerRadius = 10
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(addFoodByText), for: .touchUpInside)
        btn.isEnabled = false
        return btn
    }()
    
    private lazy var textTableView: UITableView = {
        let tv = UITableView()
        tv.dataSource = self
        tv.delegate = self
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(TextViewCell.self, forCellReuseIdentifier: "TextViewCell")
        return tv
    }()
    
    private lazy var hintLabel: UILabel = {
        let label = UILabel()
        label.text = "尚無儲存食物\n\n點擊右上角新增常用食物吧！"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .mainGreen
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let enabledButtonColor = UIColor.mainGreen
    private var foodPortion: String = "一個"
    private var foodRecord: String = ""
    
    private var foodList: [FoodItem] = []
    
    private let loadingView = LoadingView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        setupNavigationBar()
        setupView()
        loadData()
        KeyboardManager.shared.setupKeyboardManager(for: self, textFields: [portionTextField, foodTextField])
    }
    
    private func setupNavigationBar() {
        let navItem = UINavigationItem()
        navItem.leftBarButtonItem = closeButton
        navItem.rightBarButtonItem = storedFoodButton
        navItem.titleView = titleLabel
        
        navigationBar.setItems([navItem], animated: false)
        
        view.addSubview(navigationBar)
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupView() {
        
        let tabBarHeight = tabBarController?.tabBar.frame.size.height
        
        view.addSubview(textTableView)
        view.addSubview(hintLabel)
        view.addSubview(portionTextField)
        view.addSubview(foodTextField)
        view.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            portionTextField.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 10),
            portionTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            portionTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            portionTextField.heightAnchor.constraint(equalToConstant: 60),
            
            foodTextField.topAnchor.constraint(equalTo: portionTextField.bottomAnchor, constant: 10),
            foodTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            foodTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            foodTextField.heightAnchor.constraint(equalToConstant: 60),
            
            addButton.topAnchor.constraint(equalTo: foodTextField.bottomAnchor, constant: 20),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            addButton.heightAnchor.constraint(equalToConstant: 45),
            
            textTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textTableView.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 10),
            textTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(tabBarHeight ?? 80)),
            
            hintLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            hintLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            hintLabel.centerYAnchor.constraint(equalTo: textTableView.centerYAnchor)
        ])
    }
    
    @objc private func closeVC() {
        self.tabBarController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Stored Food Item
    private func loadData() {
        let foodItems = CoreDataManager.shared.fetchAllFoods()
        self.foodList = foodItems
        self.textTableView.reloadData()
        hintLabel.isHidden = !foodList.isEmpty
        textTableView.isHidden = foodList.isEmpty
    }
    
    @objc private func storedFoodTapped() {
        HapticFeedbackHelper.generateImpactFeedback()
        
        let inputViewController = InputViewController()
        let alert = UIAlertController(title: "新增食物", message: nil, preferredStyle: .actionSheet)
        alert.setValue(inputViewController, forKey: "contentViewController")
        
        let saveAction = UIAlertAction(title: "儲存", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            let name = inputViewController.nameTextField.text ?? ""
            let portion = inputViewController.portionTextField.text ?? ""
            
            if !name.isEmpty, !portion.isEmpty {
                CoreDataManager.shared.saveFood(name: name, portion: portion)
                self.loadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func addFoodByText() {
        guard foodPortion != "", foodRecord != "" else { return }
        
        loadingView.show(in: view, withBackground: true)
        
        let fullText = "\(foodPortion) \(foodRecord)"
        
        let dispatchGroup = DispatchGroup()
        var translatedText: String?
        var finalFoodRecord: FoodRecord?
        
        dispatchGroup.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            TranslationManager.shared.detectAndTranslateText(fullText) { result in
                if let result = result {
                    translatedText = result
                } else {
                    DispatchQueue.main.async {
                        self.showAlert()
                    }
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) { [weak self] in
            guard let self = self, let translatedText = translatedText else {
                self?.loadingView.hide()
                return
            }
            
            if let recordTabBarController = self.tabBarController as? RecordTabBarController,
               let mealType = recordTabBarController.selectedMealType {
                
                dispatchGroup.enter()
                DispatchQueue.global(qos: .userInitiated).async {
                    NutritionManager.shared.fetchNutritionFacts(self, mealType: mealType, ingredient: translatedText) { result in
                        finalFoodRecord = result
                        dispatchGroup.leave()
                    }
                }
            } else {
                debugLog("Tab bar controller is not of type RecordTabBarController")
                self.loadingView.hide()
            }
            
            dispatchGroup.notify(queue: DispatchQueue.main) {
                self.loadingView.hide()
                if let finalFoodRecord = finalFoodRecord {
                    self.goToNutritionVC(image: nil, foodRecord: finalFoodRecord)
                }
            }
        }
    }
}

// MARK: - TableView DataSource
extension TextVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        foodList.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < foodList.count {
            let foodItem = foodList[indexPath.row]
            // swiftlint:disable force_cast
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewCell", for: indexPath) as! TextViewCell
            // swiftlint:enable force_cast
            cell.configureCell(food: foodItem)
            cell.addStoredFood = { [weak self] food, portion in
                guard let self = self else { return }
                self.foodTextField.text = food
                self.portionTextField.text = portion
                self.foodRecord = food
                self.foodPortion = portion
                self.updateAddButtonState()
            }
            return cell
        } else {
            let cell = UITableViewCell()
            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = "點擊右上角可新增常用食物"
            cell.textLabel?.textColor = .gray
            cell.textLabel?.textAlignment = .center
            return cell
        }
    }
}

// MARK: - Table View Delegate
extension TextVC: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "刪除") { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            HapticFeedbackHelper.generateNotificationFeedback(type: .warning)
            
            let foodItemToDelete = self.foodList[indexPath.row]
            let alertController = UIAlertController(title: "確定刪除？", message: "是否要刪除此食物項目？", preferredStyle: .alert)
            
            let confirmAction = UIAlertAction(title: "刪除", style: .destructive) { _ in
                CoreDataManager.shared.deleteFood(foodItemToDelete)
                self.foodList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                completionHandler(true)
            }
            let cancelAction = UIAlertAction(title: "取消", style: .cancel) { _ in
                completionHandler(false)
            }
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

// MARK: - TextField Delegate
extension TextVC: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if textField == foodTextField {
            foodRecord = updatedText
        } else if textField == portionTextField {
            foodPortion = updatedText
        }
        updateAddButtonState()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateAddButtonState()
    }
    
    private func updateAddButtonState() {
        let isBothTextFieldsNotEmpty = !foodPortion.isEmpty && !foodRecord.isEmpty
        addButton.isEnabled = isBothTextFieldsNotEmpty
        addButton.backgroundColor = isBothTextFieldsNotEmpty ?
        enabledButtonColor : enabledButtonColor.withAlphaComponent(0.6)
        addButton.setTitleColor(isBothTextFieldsNotEmpty ? .white : .lightGray, for: .normal)
    }
}

// MARK: - Show Alert
extension TextVC {
    func showAlert() {
        HapticFeedbackHelper.generateNotificationFeedback(type: .error)
        let alert = UIAlertController(
            title: "無法辨識資料",
            message: "試試其他說法或使用英文輸入",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Go To NutritionVC
extension TextVC {
    func goToNutritionVC(image: UIImage?, foodRecord: FoodRecord?) {
        let nutritionVC = NutritionVC()
        nutritionVC.isFromText = true
        nutritionVC.checkPhoto = image
        nutritionVC.foodRecord = foodRecord
        nutritionVC.modalPresentationStyle = .fullScreen
        self.present(nutritionVC, animated: true, completion: nil)
    }
}
