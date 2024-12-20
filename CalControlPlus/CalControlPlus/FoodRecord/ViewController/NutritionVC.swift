//
//  NutritionVC.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/13.
//

import UIKit
import FirebaseFirestore

class NutritionVC: UIViewController {
    
    private lazy var navigationBar: UINavigationBar = {
        let navBar = UINavigationBar()
        navBar.isTranslucent = true
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.backgroundColor = .clear
        navBar.translatesAutoresizingMaskIntoConstraints = false
        return navBar
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.text = "分析結果"
        label.numberOfLines = 0
        label.textColor = .darkGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nutritionTableView: UITableView = {
        let tv = UITableView()
        tv.dataSource = self
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        
        tv.register(NutritionImageCell.self, forCellReuseIdentifier: NutritionImageCell.identifier)
        tv.register(NutritionTitleCell.self, forCellReuseIdentifier: NutritionTitleCell.identifier)
        tv.register(NutritionFactsCell.self, forCellReuseIdentifier: NutritionFactsCell.identifier)
        return tv
    }()
    
    private lazy var homeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .mainGreen
        let boldConfig = UIImage.SymbolConfiguration(weight: .semibold)
        let homeImage = UIImage(systemName: "house", withConfiguration: boldConfig)
        btn.setImage(homeImage, for: .normal)
        btn.tintColor = .white
        btn.layer.cornerRadius = 8
        btn.addTarget(self, action: #selector(backToHome), for: .touchUpInside)
        return btn
    }()
    
    private lazy var reselectButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .mainGreen
        btn.setTitle("重新選擇", for: .normal)
        btn.tintColor = .white
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        btn.layer.cornerRadius = 8
        btn.addTarget(self, action: #selector(reselectPhoto), for: .touchUpInside)
        return btn
    }()
    
    private lazy var recordButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .mainGreen
        btn.setTitle("紀錄此筆", for: .normal)
        btn.tintColor = .white
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        btn.layer.cornerRadius = 8
        btn.addTarget(self, action: #selector(addRecord), for: .touchUpInside)
        return btn
    }()
    
    var checkPhoto: UIImage?
    var foodRecord: FoodRecord?
    var currentDate: Date?
    
    var isFromText: Bool = true
    
    private var loadingView = LoadingView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        setupNavigationBar()
        setupTableView()
        setupButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentDate = globalCurrentDate
    }
    
    private func setupNavigationBar() {
        let navItem = UINavigationItem()
        navItem.titleView = titleLabel
        
        navigationBar.setItems([navItem], animated: false)
        
        view.addSubview(navigationBar)
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupTableView() {
        nutritionTableView.showsVerticalScrollIndicator = false
        nutritionTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nutritionTableView)
        NSLayoutConstraint.activate([
            nutritionTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nutritionTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            nutritionTableView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            nutritionTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100)
        ])
    }
    
    private func setupButtons() {
        let buttonStackView = UIStackView(arrangedSubviews: [reselectButton, recordButton])
        buttonStackView.axis = .horizontal
        buttonStackView.alignment = .center
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 20
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(buttonStackView)
        
        let homeStackView = UIStackView(arrangedSubviews: [homeButton, buttonStackView])
        homeStackView.axis = .horizontal
        homeStackView.alignment = .center
        homeStackView.distribution = .fill
        homeStackView.spacing = 20
        homeStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(homeStackView)
        
        NSLayoutConstraint.activate([
            homeButton.heightAnchor.constraint(equalToConstant: 50),
            homeButton.widthAnchor.constraint(equalToConstant: 50),
            reselectButton.heightAnchor.constraint(equalToConstant: 50),
            recordButton.heightAnchor.constraint(equalToConstant: 50),
            
            homeStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            homeStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            homeStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            homeStackView.heightAnchor.constraint(equalToConstant: 50)
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
        guard let foodRecord = foodRecord, foodRecord.title != nil else {
            showOKAlert(
                on: self,
                title: "資料缺失",
                message: "請確認輸入食物名字",
                feedbackType: .warning
            )
            return
        }
        
        loadingView.show(in: view, withBackground: true)
        
        let docRef = FirebaseManager.shared.newDocument(of: FirestoreEndpoint.foodRecord)
        
        var updatedFoodRecord = foodRecord
        updatedFoodRecord.id = docRef.documentID
        updatedFoodRecord.date = Timestamp(date: currentDate!)
        
        if let checkPhoto = checkPhoto {
            
            FirebaseManager.shared.uploadImage(
                image: checkPhoto,
                folder: .FoodRecordImages
            ) { [weak self] url in
                guard let self = self else {
                    showOKAlert(
                        on: self ?? UIViewController(),
                        title: "錯誤",
                        message: "儲存失敗，請稍後再試。",
                        feedbackType: .error
                    )
                    self?.loadingView.hide()
                    return
                }
                
                if let url = url {
                    updatedFoodRecord.imageUrl = url.absoluteString
                }
                self.saveRecord(updatedFoodRecord, to: docRef)
            }
        } else {
            
            saveRecord(updatedFoodRecord, to: docRef)
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
            let cell: NutritionImageCell = tableView.dequeueReusableCell(
                withIdentifier: NutritionImageCell.identifier, for: indexPath
            )
            cell.configureCell(image: checkPhoto, name: foodRecord?.title)
            cell.didChangedPhoto = { [weak self] selectedImage in
                self?.checkPhoto = selectedImage
            }
            return cell
            
        } else if indexPath.row == 1 {
            let cell: NutritionTitleCell = tableView.dequeueReusableCell(
                withIdentifier: NutritionTitleCell.identifier, for: indexPath
            )
            cell.configureCell(title: foodRecord?.title)
            cell.didUpdateTitle = { [weak self] newTitle in
                guard let strongSelf = self else { return }
                strongSelf.foodRecord?.title = newTitle
                
                let indexPathForImageCell = IndexPath(row: 0, section: 0)
                strongSelf.nutritionTableView.reloadRows(at: [indexPathForImageCell], with: .automatic)
            }
            KeyboardManager.shared.setupKeyboardManager(for: self, textFields: [cell.titleTextField])
            return cell
            
        } else if indexPath.row == 2 {
            let cell: NutritionFactsCell = tableView.dequeueReusableCell(
                withIdentifier: NutritionFactsCell.identifier, for: indexPath
            )
            if let foodRecord = foodRecord {
                cell.configureCell(nutritionFacts: foodRecord.nutritionFacts)
            }
            return cell
        }
        return UITableViewCell()
    }
}

// MARK: - Save Record To Firebase
extension NutritionVC {
    private func saveRecord(_ foodRecord: FoodRecord, to docRef: DocumentReference) {
        FirebaseManager.shared.setData(foodRecord, at: docRef)
        
        loadingView.hide()
        
        HapticFeedbackHelper.generateNotificationFeedback(type: .success)
        let alert = UIAlertController(title: "儲存成功！", message: nil, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            alert.dismiss(animated: true) {
                self.backToHome()
            }
        }
    }
}
