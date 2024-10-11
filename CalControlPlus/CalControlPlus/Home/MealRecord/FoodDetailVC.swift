//
//  FoodDetailVC.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/26.
//

import UIKit

class FoodDetailVC: UIViewController {
    
    private lazy var foodDetailTableView: UITableView = {
        let tv = UITableView()
        tv.dataSource = self
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(NutritionImageCell.self, forCellReuseIdentifier: NutritionImageCell.identifier)
        tv.register(FoodDetailCell.self, forCellReuseIdentifier: FoodDetailCell.identifier)
        tv.register(DeleteButtonCell.self, forCellReuseIdentifier: DeleteButtonCell.identifier)
        return tv
    }()
    
    private lazy var changeButtonItem = UIBarButtonItem(
        image: UIImage(systemName: "rectangle.and.pencil.and.ellipsis"),
        style: .plain,
        target: self,
        action: #selector(toggleEditing)
    )
    
    var foodRecord: FoodRecord?
    private var isEditingMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        navigationItem.rightBarButtonItem = changeButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let mainTabBarController = self.tabBarController as? MainTabBarController {
            mainTabBarController.plusButtonAnimationView.isHidden = true
        }
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let mainTabBarController = self.tabBarController as? MainTabBarController {
            mainTabBarController.plusButtonAnimationView.isHidden = false
        }
        self.tabBarController?.tabBar.isHidden = false
    }
    
    private func setupView() {
        view.addSubview(foodDetailTableView)
        
        NSLayoutConstraint.activate([
            foodDetailTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            foodDetailTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            foodDetailTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            foodDetailTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

// MARK: - TableView DataSource
extension FoodDetailVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: NutritionImageCell.identifier, for: indexPath
            ) as? NutritionImageCell else {
                return UITableViewCell()
            }
            if let foodRecord = foodRecord {
                cell.configureCell(image: foodRecord.imageUrl, name: foodRecord.title)
            }
            return cell
        } else if indexPath.row == 1 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: FoodDetailCell.identifier, for: indexPath
            ) as? FoodDetailCell else {
                return UITableViewCell()
            }
            if let foodRecord = foodRecord {
                cell.configure(with: foodRecord)
                let allTextFields = Array(cell.valueTextFields.values) + [cell.titleTextField]
                KeyboardManager.shared.setupKeyboardManager(for: self, textFields: allTextFields)
            }
            cell.isEditingMode = isEditingMode
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: DeleteButtonCell.identifier, for: indexPath
            ) as? DeleteButtonCell else {
                return UITableViewCell()
            }
            cell.deleteButton.addTarget(self, action: #selector(deleteFoodRecord), for: .touchUpInside)
            return cell
        }
    }
}

// MARK: - Update Data
extension FoodDetailVC {
    @objc private func toggleEditing() {
        isEditingMode.toggle()
        
        foodDetailTableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
        
        guard !isEditingMode,
              let foodDetailCell = foodDetailTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? FoodDetailCell,
              let originalFoodRecord = foodRecord else { return }
        
        let updatedTitle = foodDetailCell.titleTextField.text ?? originalFoodRecord.title
        
        let updatedNutritionFacts = NutritionFacts(
            weight: Nutrient(
                value: Double(
                    foodDetailCell.valueTextFields["份量"]?.text ?? ""
                ) ?? originalFoodRecord.nutritionFacts.weight.value,
                unit: originalFoodRecord.nutritionFacts.weight.unit
            ),
            calories: Nutrient(
                value: Double(
                    foodDetailCell.valueTextFields["熱量"]?.text ?? ""
                ) ?? originalFoodRecord.nutritionFacts.calories.value,
                unit: originalFoodRecord.nutritionFacts.calories.unit
            ),
            carbs: Nutrient(
                value: Double(
                    foodDetailCell.valueTextFields["碳水化合物"]?.text ?? ""
                ) ?? originalFoodRecord.nutritionFacts.carbs.value,
                unit: originalFoodRecord.nutritionFacts.carbs.unit
            ),
            fats: Nutrient(
                value: Double(
                    foodDetailCell.valueTextFields["脂質"]?.text ?? ""
                ) ?? originalFoodRecord.nutritionFacts.fats.value,
                unit: originalFoodRecord.nutritionFacts.fats.unit
            ),
            protein: Nutrient(
                value: Double(
                    foodDetailCell.valueTextFields["蛋白質"]?.text ?? ""
                ) ?? originalFoodRecord.nutritionFacts.protein.value,
                unit: originalFoodRecord.nutritionFacts.protein.unit
            )
        )
        
        if updatedTitle != originalFoodRecord.title || updatedNutritionFacts != originalFoodRecord.nutritionFacts {
            let updatedFoodRecord = FoodRecord(
                title: updatedTitle,
                mealType: originalFoodRecord.mealType,
                id: originalFoodRecord.id,
                userID: originalFoodRecord.userID,
                date: originalFoodRecord.date,
                nutritionFacts: updatedNutritionFacts,
                imageUrl: originalFoodRecord.imageUrl
            )
            
            updateFoodRecordInFirebase(updatedFoodRecord) { [weak self] success in
                if success {
                    self?.foodRecord = updatedFoodRecord
                    self?.foodDetailTableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
                }
            }
        }
    }
    
    private func updateFoodRecordInFirebase(_ updatedFoodRecord: FoodRecord, completion: @escaping (Bool) -> Void) {
        guard let foodRecordID = foodRecord?.id else { return }
        
        let updatedData: [String: Any] = [
            "title": updatedFoodRecord.title ?? "",
            "nutritionFacts": [
                "weight": [
                    "value": updatedFoodRecord.nutritionFacts.weight.value,
                    "unit": updatedFoodRecord.nutritionFacts.weight.unit
                ],
                "calories": [
                    "value": updatedFoodRecord.nutritionFacts.calories.value,
                    "unit": updatedFoodRecord.nutritionFacts.calories.unit
                ],
                "carbs": [
                    "value": updatedFoodRecord.nutritionFacts.carbs.value,
                    "unit": updatedFoodRecord.nutritionFacts.carbs.unit
                ],
                "fats": [
                    "value": updatedFoodRecord.nutritionFacts.fats.value,
                    "unit": updatedFoodRecord.nutritionFacts.fats.unit
                ],
                "protein": [
                    "value": updatedFoodRecord.nutritionFacts.protein.value,
                    "unit": updatedFoodRecord.nutritionFacts.protein.unit
                ]
            ]
        ]
        
        FirebaseManager.shared.updateDocument(
            from: .foodRecord,
            documentID: foodRecordID,
            data: updatedData,
            merge: true
        ) { result in
            if result == true {
                debugLog("Successfully updated food record in firebase")
                completion(true)
            } else {
                debugLog("Error - Failed to update food record in firebase")
                completion(false)
            }
        }
    }
}

// MARK: - Delete Data
extension FoodDetailVC {
    @objc private func deleteFoodRecord() {
        HapticFeedbackHelper.generateNotificationFeedback(type: .warning)
        let alertController = UIAlertController(
            title: "確認刪除",
            message: "您確定要刪除此食物紀錄嗎？",
            preferredStyle: .alert
        )
        let deleteAction = UIAlertAction(title: "刪除", style: .destructive) { [weak self] _ in
            self?.deleteRecordFromFirebase()
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func deleteRecordFromFirebase() {
        guard let foodRecordID = foodRecord?.id else { return }
        FirebaseManager.shared.deleteDocument(
            from: .foodRecord, documentID: foodRecordID
        ) { result in
            if result == true {
                debugLog("Successfully deleted food record from firebase")
                self.navigationController?.popViewController(animated: true)
            } else {
                debugLog("Error - Failed to delete food record from firebase")
            }
        }
    }
}
