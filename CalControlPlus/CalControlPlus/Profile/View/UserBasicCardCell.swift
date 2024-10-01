//
//  UserBasicCardCell.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/23.
//

import UIKit
import Combine
import FirebaseCore

class UserBasicCardCell: BaseCardTableViewCell {
    
    static let identifier = "UserBasicCardCell"
    
    var viewModel = UserProfileViewModel.shared!
    private var subscriptions = Set<AnyCancellable>()
    
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let weightOptions: [Double] = Array(stride(from: 30.0, to: 150.1, by: 0.1))
    
    var currentPickerType: PickerType?
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        addBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        innerContentView.addSubview(verticalStackView)
        
        NSLayoutConstraint.activate([
            verticalStackView.leadingAnchor.constraint(equalTo: innerContentView.leadingAnchor, constant: 16),
            verticalStackView.trailingAnchor.constraint(equalTo: innerContentView.trailingAnchor, constant: -16),
            verticalStackView.topAnchor.constraint(equalTo: innerContentView.topAnchor, constant: 16),
            verticalStackView.bottomAnchor.constraint(equalTo: innerContentView.bottomAnchor, constant: -16)
        ])
        
        addRow(leftText: "性別",
               rightView: createTitleAndArrowStack(
                title: viewModel.user.gender.description()
               ))
        addRow(leftText: "身高",
               rightView: createTitleAndArrowStack(
                title: "\(viewModel.user.height) cm"
               ))
        addRow(leftText: "生日",
               rightView: createTitleAndArrowStack(
                title: "\(viewModel.user.birthday)"
               ))
        if let weight = viewModel.user.weightRecord.last?.weight {
            addRow(leftText: "體重",
                   rightView: createTitleAndArrowStack(
                    title: "\(String(format: "%.1f", weight)) kg"))
        } else {
            addRow(leftText: "體重",
                   rightView: createTitleAndArrowStack(title: "N/A"))
        }
        addRow(leftText: "日常活動量",
               rightView: createTitleAndArrowStack(
                title: viewModel.user.activity.description()
               ))
        addRow(leftText: "目標",
               rightView: createTitleAndArrowStack(
                title: viewModel.user.target.description()
               ))
    }
    
    private func addBindings() {
        viewModel.$user
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                guard let self = self else { return }
                if let genderStack = self.verticalStackView.arrangedSubviews[0] as? UIStackView,
                   let rightStack = genderStack.arrangedSubviews[1] as? UIStackView,
                   let genderLabel = rightStack.arrangedSubviews[0] as? UILabel {
                    genderLabel.text = user.gender.description()
                }
                
                if let heightStack = self.verticalStackView.arrangedSubviews[1] as? UIStackView,
                   let rightStack = heightStack.arrangedSubviews[1] as? UIStackView,
                   let heightLabel = rightStack.arrangedSubviews[0] as? UILabel {
                    heightLabel.text = "\(String(format: "%.0f", user.height)) cm"
                }
                
                if let birthdayStack = self.verticalStackView.arrangedSubviews[2] as? UIStackView,
                   let rightStack = birthdayStack.arrangedSubviews[1] as? UIStackView,
                   let birthdayLabel = rightStack.arrangedSubviews[0] as? UILabel {
                    birthdayLabel.text = user.birthday
                }
                
                if let weightStack = self.verticalStackView.arrangedSubviews[3] as? UIStackView,
                   let rightStack = weightStack.arrangedSubviews[1] as? UIStackView,
                   let weightLabel = rightStack.arrangedSubviews[0] as? UILabel {
                    weightLabel.text = "\(String(format: "%.1f", user.weightRecord.last!.weight)) kg"
                }
                
                if let activityStack = self.verticalStackView.arrangedSubviews[4] as? UIStackView,
                   let rightStack = activityStack.arrangedSubviews[1] as? UIStackView,
                   let activityLabel = rightStack.arrangedSubviews[0] as? UILabel {
                    activityLabel.text = user.activity.description()
                }
                
                if let targetStack = self.verticalStackView.arrangedSubviews[5] as? UIStackView,
                   let rightStack = targetStack.arrangedSubviews[1] as? UIStackView,
                   let targetLabel = rightStack.arrangedSubviews[0] as? UILabel {
                    targetLabel.text = user.target.description()
                }
            }
            .store(in: &subscriptions)
    }
    
    private func createTitleAndArrowStack(title: String) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = .darkGray
        
        let arrowImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrowImageView.tintColor = .lightGray
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, arrowImageView])
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }
    
    private func addRow(leftText: String, rightView: UIView) {
        let horizontalStackView = UIStackView()
        horizontalStackView.axis = .horizontal
        horizontalStackView.alignment = .center
        horizontalStackView.distribution = .equalSpacing
        horizontalStackView.spacing = 8
        
        let leftLabel = UILabel()
        leftLabel.text = leftText
        leftLabel.font = UIFont.systemFont(ofSize: 16)
        
        horizontalStackView.addArrangedSubview(leftLabel)
        horizontalStackView.addArrangedSubview(rightView)
        
        verticalStackView.addArrangedSubview(horizontalStackView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(rowTappedAction(_:)))
        horizontalStackView.addGestureRecognizer(tapGesture)
        horizontalStackView.isUserInteractionEnabled = true
        horizontalStackView.tag = verticalStackView.arrangedSubviews.count - 1
    }
    
    @objc private func rowTappedAction(_ sender: UITapGestureRecognizer) {
        guard let tappedRow = sender.view?.tag else { return }
        
        switch tappedRow {
        case 0:
            showPicker(for: .gender)
        case 1:
            showPicker(for: .height)
        case 2:
            showDatePicker()
        case 3:
            if let vc = self.findViewController() {
                vc.performSegue(withIdentifier: "showWeightRecordDetailFromProfile", sender: self)
            }
        case 4:
            showPicker(for: .activityLevel)
        case 5:
            showPicker(for: .target)
        default:
            return
        }
    }
}

// MARK: - UIPickerViewDelegate and UIPickerViewDataSource Methods
extension UserBasicCardCell: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return createPickerData(for: currentPickerType ?? .gender).options.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let pickerData = createPickerData(for: currentPickerType ?? .gender)
        return pickerData.options[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
}

// MARK: - PickerView Selection
extension UserBasicCardCell {
    private func showPicker(for pickerType: PickerType) {
        let modalVC = ModalVC()
        let pickerViewModal = PickerViewModal()
        
        currentPickerType = pickerType
        
        let pickerData = createPickerData(for: pickerType)
        pickerViewModal.pickerView.delegate = self
        pickerViewModal.pickerView.dataSource = self
        pickerViewModal.pickerView.selectRow(pickerData.selectedIndex, inComponent: 0, animated: false)
        
        pickerViewModal.confirmAction = { [weak self] in
            guard let self = self else { return }
            let selectedRow = pickerViewModal.pickerView.selectedRow(inComponent: 0)
            self.handlePickerSelection(for: pickerType, selectedIndex: selectedRow)
            modalVC.dismissModal()
        }
        
        pickerViewModal.cancelAction = {
            modalVC.dismissModal()
        }
        
        modalVC.pickerViewModal = pickerViewModal
        modalVC.modalPresentationStyle = .overFullScreen
        modalVC.modalTransitionStyle = .crossDissolve
        
        if let viewController = self.findViewController() {
            viewController.present(modalVC, animated: false) {
                modalVC.presentModal()
            }
        }
    }
    
    private func showDatePicker() {
        let modalVC = ModalVC()
        let datePickerModal = DatePickerModal()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let savedBirthday = dateFormatter.date(from: viewModel.user.birthday) {
            datePickerModal.datePicker.date = savedBirthday
        } else {
            datePickerModal.datePicker.date = Date()
        }
        
        datePickerModal.confirmAction = { [weak self] in
            guard let self = self else { return }
            let selectedDate = datePickerModal.datePicker.date
            self.handleDatePickerSelection(selectedDate)
            modalVC.dismissModal()
        }
        
        datePickerModal.cancelAction = {
            modalVC.dismissModal()
        }
        
        modalVC.pickerViewModal = datePickerModal
        modalVC.modalPresentationStyle = .overFullScreen
        modalVC.modalTransitionStyle = .crossDissolve
        
        if let viewController = self.findViewController() {
            viewController.present(modalVC, animated: false) {
                modalVC.presentModal()
            }
        }
    }
    
    private func createPickerData(for pickerType: PickerType) -> PickerData {
        switch pickerType {
        case .gender:
            let options = Gender.allCases.map { $0.description() }
            let selectedIndex = viewModel.user.gender.rawValue
            return PickerData(type: .gender, options: options, selectedIndex: selectedIndex)
        case .height:
            let options = (140...210).map { "\($0) cm" }
            let selectedIndex = options.firstIndex(of: "\(Int(viewModel.user.height)) cm") ?? 0
            return PickerData(type: .height, options: options, selectedIndex: selectedIndex)
        case .activityLevel:
            let options = ActivityLevel.allCases.map { $0.description() }
            let selectedIndex = ActivityLevel.allCases.firstIndex(of: viewModel.user.activity) ?? 0
            return PickerData(type: .activityLevel, options: options, selectedIndex: selectedIndex)
        case .target:
            let options = Target.allCases.map { $0.description() }
            let selectedIndex = Target.allCases.firstIndex(of: viewModel.user.target) ?? 0
            return PickerData(type: .target, options: options, selectedIndex: selectedIndex)
        }
    }
    
    private func handlePickerSelection(for pickerType: PickerType, selectedIndex: Int) {
        switch pickerType {
        case .gender:
            self.viewModel.user.gender = Gender.allCases[selectedIndex]
            uploadToFirebase(data: ["gender": Gender.allCases[selectedIndex].rawValue])
        case .height:
            self.viewModel.user.height = Double(140 + selectedIndex)
            uploadToFirebase(data: ["height": Double(140 + selectedIndex)])
        case .activityLevel:
            self.viewModel.user.activity = ActivityLevel.allCases[selectedIndex]
            uploadToFirebase(data: ["activity": ActivityLevel.allCases[selectedIndex].rawValue])
        case .target:
            self.viewModel.user.target = Target.allCases[selectedIndex]
            uploadToFirebase(data: ["target": Target.allCases[selectedIndex].rawValue])
        }
    }
    
    private func handleDatePickerSelection(_ selectedDate: Date) {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: selectedDate)
        
        self.viewModel.user.birthday = dateString
        
        uploadToFirebase(data: ["birthday": dateString])
    }
    
    private func uploadToFirebase(data: [String: Any]) {
        FirebaseManager.shared.updateDocument(
            from: .users,
            documentID: UserProfileViewModel.shared.user.id,
            data: data) { result in
                if result == true {
                    print("Success upload to firebase")
                } else {
                    print("Error: Failed to upload to firebase")
                }
            }
    }
}
