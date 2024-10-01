//
//  WeightRecordDetailVC.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/26.
//

import UIKit

class WeightRecordDetailVC: UIViewController {
    private lazy var weightRecordTableView: UITableView = {
        let tv = UITableView()
        tv.dataSource = self
        tv.delegate = self
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(WeightRecordDetailCell.self, forCellReuseIdentifier: WeightRecordDetailCell.identifier)
        return tv
    }()
    
    private var sortedWeightRecords: [WeightRecord] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "編輯",
            style: .plain,
            target: self,
            action: #selector(toggleEditing)
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = true
        sortedWeightRecords = UserProfileViewModel.shared.user.weightRecord.sorted {
            $0.date.dateValue() > $1.date.dateValue()
        }
        weightRecordTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @objc private func toggleEditing() {
        weightRecordTableView.setEditing(!weightRecordTableView.isEditing, animated: true)
        navigationItem.rightBarButtonItem?.title = weightRecordTableView.isEditing ? "完成" : "編輯"
    }
    
    private func setupView() {
        let titleLabel = UILabel()
        titleLabel.text = "體重紀錄"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont(name: "Helvetica Neue", size: 28)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        view.addSubview(weightRecordTableView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            weightRecordTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            weightRecordTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            weightRecordTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            weightRecordTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

// MARK: - TableView DataSource
extension WeightRecordDetailVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedWeightRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: WeightRecordDetailCell.identifier, for: indexPath
        ) as? WeightRecordDetailCell else {
            return UITableViewCell()
        }
        
        let weightData = sortedWeightRecords[indexPath.row]
        cell.configure(with: weightData)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteWeightRecord(at: indexPath)
        }
    }
    
    private func updateWeightRecordsInFirebase() {
        let userID = UserProfileViewModel.shared.user.id
        let docRef = FirestoreEndpoint.users.ref.document(userID)
        
        FirebaseManager.shared.setData(
            ["weightRecord": UserProfileViewModel.shared.user.weightRecord],
            at: docRef,
            merge: true
        )
    }
}

// MARK: - TableView Delegate
extension WeightRecordDetailVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let editAction = UIContextualAction(
            style: .normal, title: "更改"
        ) { [weak self] (_, _, completionHandler) in
            self?.presentEditAlert(for: indexPath)
            completionHandler(true)
        }
        editAction.backgroundColor = .systemBlue
        
        let deleteAction = UIContextualAction(
            style: .destructive, title: "刪除"
        ) { [weak self] (_, _, completionHandler) in
            self?.deleteWeightRecord(at: indexPath)
            completionHandler(true)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return configuration
    }
    
    private func deleteWeightRecord(at indexPath: IndexPath) {
        let recordToRemove = sortedWeightRecords[indexPath.row]
        if let originalIndex = UserProfileViewModel.shared.user.weightRecord.firstIndex(where: { $0.date == recordToRemove.date }) {
            UserProfileViewModel.shared.user.weightRecord.remove(at: originalIndex)
        }
        
        sortedWeightRecords.remove(at: indexPath.row)
        updateWeightRecordsInFirebase()
        
        weightRecordTableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    private func presentEditAlert(for indexPath: IndexPath) {
        let weightData = sortedWeightRecords[indexPath.row]
        
        let alertController = UIAlertController(title: "更改體重", message: "請輸入新的體重", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "體重"
            textField.keyboardType = .decimalPad
            textField.text = "\(weightData.weight)"
        }
        
        let confirmAction = UIAlertAction(title: "確認", style: .default) { [weak self, weak alertController] _ in
            guard let self = self, let textField = alertController?.textFields?.first,
                  let newWeightText = textField.text, let newWeight = Double(newWeightText) else { return }
            
            if let originalIndex = UserProfileViewModel.shared.user.weightRecord.firstIndex(where: { $0.date == weightData.date }) {
                UserProfileViewModel.shared.user.weightRecord[originalIndex].weight = newWeight
            }
            
            self.sortedWeightRecords[indexPath.row].weight = newWeight
            self.updateWeightRecordsInFirebase()
            self.weightRecordTableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
}
