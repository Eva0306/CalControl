//
//  NutritionVC.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/13.
//

import UIKit

class NutritionVC: UIViewController {
    
    private var nutritionTableView = UITableView()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        
        nutritionTableView.register(NutritionImageCell.self, forCellReuseIdentifier: "NutritionImageCell")
        nutritionTableView.register(NutritionTitleCell.self, forCellReuseIdentifier: "NutritionTitleCell")
        nutritionTableView.register(NutritionFactsCell.self, forCellReuseIdentifier: "NutritionFactsCell")
    }
    
    private func setupTableView() {
        nutritionTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nutritionTableView)
        NSLayoutConstraint.activate([
            nutritionTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nutritionTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            nutritionTableView.topAnchor.constraint(equalTo: view.topAnchor),
            nutritionTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -70)
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
        
        presentingViewController?.presentingViewController?.dismiss(animated: true, completion: {
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let mainTabBarController = window.rootViewController as? UITabBarController {
                mainTabBarController.selectedIndex = 0
            }
        })
    }
    
    @objc private func reselectPhoto() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func addRecord() {
        
    }

}

extension NutritionVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "NutritionImageCell", for: indexPath)
            
            return cell
            
        } else if indexPath.row == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "NutritionTitleCell", for: indexPath)
            
            return cell
            
        } else if indexPath.row == 2 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "NutritionFactsCell", for: indexPath)
            
            return cell
            
        }
        return UITableViewCell()
    }
}
