//
//  TextVC.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/11.
//

import UIKit

class TextVC: UIViewController {
    
    private lazy var closeButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "xmark"), for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.contentHorizontalAlignment = .fill
        btn.contentVerticalAlignment = .fill
        btn.tintColor = .darkGray
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(closeVC), for: .touchUpInside)
        return btn
    }()
    
    private lazy var foodTextField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 10
        tf.placeholder = "輸入食物種類"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    lazy var addButton : UIButton = {
        let btn = UIButton()
        btn.setTitle("新增", for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = .mainGreen
        btn.layer.cornerRadius = 10
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private lazy var textTableView: UITableView = {
        let tv = UITableView()
        tv.dataSource = self
        // tv.delegate = self
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(TextViewCell.self, forCellReuseIdentifier: "TextViewCell")
        return tv
    }()
    
    private var foodList: [[String]] = [["荷包蛋", "一顆"], ["白飯", "一碗"], ["雞胸肉", "一片, 150g"], ["青菜", "一份, 100g"], ["雞胸肉", "一片, 150g"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        setupView()
    }
    
    private func setupView() {
        
        let tabBarHeight = tabBarController?.tabBar.frame.size.height
        
        view.addSubview(textTableView)
        view.addSubview(closeButton)
        view.addSubview(foodTextField)
        view.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 20),
            closeButton.heightAnchor.constraint(equalToConstant: 20),
            
            foodTextField.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 30),
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
            textTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(tabBarHeight ?? 80))
        ])
    }
    
    @objc private func closeVC() {
        self.tabBarController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - TableView DataSource
extension TextVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        foodList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let food = foodList[indexPath.row]
        // swiftlint:disable force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewCell", for: indexPath) as! TextViewCell
        // swiftlint:enable force_cast
        cell.configureCell(food: food)
        return cell
    }
}
