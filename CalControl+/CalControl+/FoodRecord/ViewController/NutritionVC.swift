//
//  NutritionVC.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/13.
//

import UIKit
import FirebaseCore

class NutritionVC: UIViewController {
    
    private lazy var nutritionTableView: UITableView = {
        let tv = UITableView()
        tv.dataSource = self
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        // tv.delegate = self
        
        tv.register(NutritionImageCell.self, forCellReuseIdentifier: "NutritionImageCell")
        tv.register(NutritionTitleCell.self, forCellReuseIdentifier: "NutritionTitleCell")
        tv.register(NutritionFactsCell.self, forCellReuseIdentifier: "NutritionFactsCell")
        return tv
    }()
    
    private lazy var homeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Home", for: .normal)
        btn.addTarget(self, action: #selector(backToHome), for: .touchUpInside)
        return btn
    }()
    
    private lazy var reselectButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Reselect", for: .normal)
        btn.addTarget(self, action: #selector(reselectPhoto), for: .touchUpInside)
        return btn
    }()
    
    private lazy var recordButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Record", for: .normal)
        btn.addTarget(self, action: #selector(addRecord), for: .touchUpInside)
        return btn
    }()
    
    var checkPhoto: UIImage?
    
    var nutritionFacts: NutritionFacts?
    
    var isFromText: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        
        setupTableView()
        setupButtons()
    }
    
    private func setupTableView() {
        nutritionTableView.showsVerticalScrollIndicator = false
        nutritionTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nutritionTableView)
        NSLayoutConstraint.activate([
            nutritionTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nutritionTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            nutritionTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            nutritionTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)
        ])
    }
    
    private func setupButtons() {
        let buttonStackView = UIStackView(arrangedSubviews: [homeButton, reselectButton, recordButton])
        buttonStackView.axis = .horizontal
        buttonStackView.alignment = .center
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 20
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(buttonStackView)
        
        NSLayoutConstraint.activate([
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            buttonStackView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func backToHome() {
        let vc: UIViewController?
        
        if isFromText {
            vc = presentingViewController?.presentingViewController
        } else {
            vc = presentingViewController?.presentingViewController?.presentingViewController
        }
        
        vc?.dismiss(animated: true, completion: {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let mainTabBarController = window.rootViewController as? UITabBarController {
                mainTabBarController.selectedIndex = 0
            }
        })
    }
    
    @objc private func reselectPhoto() {
        if isFromText {
            self.dismiss(animated: true)
        } else {
            presentingViewController?.presentingViewController?.dismiss(animated: true)
        }
    }
    
    @objc private func addRecord() {
        guard let nutritionFacts = nutritionFacts, let title = nutritionFacts.title else {
            showAlert()
            return
        }
        let docRef = FirebaseManager.shared.newDocument(of: FirestoreEndpoint.foodRecord)
        let foodRecord = FoodRecord(id: docRef.documentID,
                                    user_id: "Eva123",
                                    date: Timestamp(date: Date()),
                                    nutritionFacts: nutritionFacts,
                                    imageUrl: nil)
        FirebaseManager.shared.setData(foodRecord, at: docRef)
        
        let alert = UIAlertController(title: "儲存成功！", message: nil, preferredStyle: .alert)
        present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            alert.dismiss(animated: true) {
                self.backToHome()
            }
        }
    }

}

// MARK: - Tableview DataSource
extension NutritionVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            // swiftlint:disable force_cast line_length
            let cell = tableView.dequeueReusableCell(withIdentifier: "NutritionImageCell", for: indexPath) as! NutritionImageCell
            // swiftlint:enable force_cast line_length
            cell.configureCell(image: checkPhoto, name: nutritionFacts?.title)
            
            return cell
            
        } else if indexPath.row == 1 {
            // swiftlint:disable force_cast  line_length
            let cell = tableView.dequeueReusableCell(withIdentifier: "NutritionTitleCell", for: indexPath) as! NutritionTitleCell
            // swiftlint:enable force_cast line_length
            cell.configureCell(title: nutritionFacts?.title)
            
            cell.didUpdateTitle = { [weak self] newTitle in
                guard let strongSelf = self else { return }
                strongSelf.nutritionFacts?.title = newTitle
                
                let indexPathForImageCell = IndexPath(row: 0, section: 0)
                strongSelf.nutritionTableView.reloadRows(at: [indexPathForImageCell], with: .automatic)
            }
            
            return cell
            
        } else if indexPath.row == 2 {
            // swiftlint:disable force_cast line_length
            let cell = tableView.dequeueReusableCell(withIdentifier: "NutritionFactsCell", for: indexPath) as! NutritionFactsCell
            // swiftlint:enable force_cast line_length
            if let nutritionFacts = nutritionFacts {
                cell.configureCell(nutritionFacts: nutritionFacts)
            }
            
            return cell
        }
        return UITableViewCell()
    }
}

// MARK: - Show Alert
extension NutritionVC {
    func showAlert() {
        let alert = UIAlertController(
            title: "資料缺失",
            message: "請確認輸入食物名字",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }
}
