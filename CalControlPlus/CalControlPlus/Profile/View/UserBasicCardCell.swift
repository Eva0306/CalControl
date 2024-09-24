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
    let yearOptions = Array(1900...Calendar.current.component(.year, from: Date()))
    let monthOptions = Array(1...12)
    var dayOptions = Array(1...31)
    
    var currentPickerType: PickerType?
    var selectedYearIndex = 0
    var selectedMonthIndex = 0
    var selectedDayIndex = 0
    
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
               rightView: createTitleAndArrowStack(title: viewModel.user.gender.description()))
        addRow(leftText: "身高",
               rightView: createTitleAndArrowStack(title: "\(viewModel.user.height) cm"))
        addRow(leftText: "生日",
               rightView: createTitleAndArrowStack(title: "\(viewModel.user.birthday)"))
        addRow(leftText: "體重",
               rightView: createTitleAndArrowStack(title: "\(String(format: "%.1f", viewModel.user.weightRecord.last!.weight)) kg"))
        addRow(leftText: "日常活動量",
               rightView: createTitleAndArrowStack(title: viewModel.user.activity.description()))
        addRow(leftText: "目標",
               rightView: createTitleAndArrowStack(title: viewModel.user.target.description()))
    }
    
    private func addBindings() {
        viewModel.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                
                if let genderStack = self?.verticalStackView.arrangedSubviews[0] as? UIStackView,
                   let rightStack = genderStack.arrangedSubviews[1] as? UIStackView,
                   let genderLabel = rightStack.arrangedSubviews[0] as? UILabel {
                    genderLabel.text = user.gender.description()
                }
                
                if let heightStack = self?.verticalStackView.arrangedSubviews[1] as? UIStackView,
                   let rightStack = heightStack.arrangedSubviews[1] as? UIStackView,
                   let heightLabel = rightStack.arrangedSubviews[0] as? UILabel {
                    heightLabel.text = "\(String(format: "%.0f", user.height)) cm"
                }
                
                if let birthdayStack = self?.verticalStackView.arrangedSubviews[2] as? UIStackView,
                   let rightStack = birthdayStack.arrangedSubviews[1] as? UIStackView,
                   let birthdayLabel = rightStack.arrangedSubviews[0] as? UILabel {
                    birthdayLabel.text = user.birthday
                }
                
                if let weightStack = self?.verticalStackView.arrangedSubviews[3] as? UIStackView,
                   let rightStack = weightStack.arrangedSubviews[1] as? UIStackView,
                   let weightLabel = rightStack.arrangedSubviews[0] as? UILabel {
                    weightLabel.text = "\(String(format: "%.1f", user.weightRecord.last!.weight)) kg"
                }
                
                if let activityStack = self?.verticalStackView.arrangedSubviews[4] as? UIStackView,
                   let rightStack = activityStack.arrangedSubviews[1] as? UIStackView,
                   let activityLabel = rightStack.arrangedSubviews[0] as? UILabel {
                    activityLabel.text = user.activity.description()
                }
                
                if let targetStack = self?.verticalStackView.arrangedSubviews[5] as? UIStackView,
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
        
        let tappedRowText: String
        switch tappedRow {
        case 0:
            showPicker(for: .gender)
        case 1:
            showPicker(for: .height)
        case 2:
            showPicker(for: .birthday)
        case 3:
            showPicker(for: .weight)
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
        switch currentPickerType {
        case .birthday:
            return 3
        default:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch currentPickerType {
        case .birthday:
            switch component {
            case 0: return yearOptions.count
            case 1: return monthOptions.count
            case 2: return dayOptions.count
            default: return 0
            }
        default:
            return createPickerData(for: currentPickerType ?? .gender).options.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch currentPickerType {
        case .birthday:
            switch component {
            case 0: return "\(yearOptions[row])"
            case 1: return "\(monthOptions[row])"
            case 2: return "\(dayOptions[row])"
            default: return nil
            }
        default:
            let pickerData = createPickerData(for: currentPickerType ?? .gender)
            return pickerData.options[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if currentPickerType == .birthday {
            switch component {
            case 0:
                selectedYearIndex = row
            case 1:
                selectedMonthIndex = row
                updateDayOptions()
                pickerView.reloadComponent(2)
            case 2:
                selectedDayIndex = row
            default:
                break
            }
        }
    }
}

// MARK: - PickerView Selection
extension UserBasicCardCell {
    private func showPicker(for pickerType: PickerType) {
        let modalVC = ModalVC()
        
        let pickerData = createPickerData(for: pickerType)
        currentPickerType = pickerType
        
        modalVC.pickerViewModal.pickerView.delegate = self
        modalVC.pickerViewModal.pickerView.dataSource = self
        
        if pickerType == .birthday {
            setupBirthdayPickerDefaults()
            modalVC.pickerViewModal.pickerView.selectRow(selectedYearIndex, inComponent: 0, animated: false)
            modalVC.pickerViewModal.pickerView.selectRow(selectedMonthIndex, inComponent: 1, animated: false)
            modalVC.pickerViewModal.pickerView.selectRow(selectedDayIndex, inComponent: 2, animated: false)
        } else {
            modalVC.pickerViewModal.pickerView.selectRow(pickerData.selectedIndex, inComponent: 0, animated: false)
        }
        
        modalVC.pickerViewModal.confirmAction = { [weak self] in
            guard let self = self else { return }
            let selectedRow = modalVC.pickerViewModal.pickerView.selectedRow(inComponent: 0)
            
            self.handlePickerSelection(for: pickerType, selectedIndex: selectedRow)
            modalVC.dismissModal()
        }
        
        modalVC.pickerViewModal.cancelAction = {
            modalVC.dismissModal()
        }
        
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
        case .birthday:
            return PickerData(type: .birthday, options: [], selectedIndex: 0)
        case .weight:
            let options = weightOptions.map { String(format: "%.1f", $0) + " kg" }
            let selectedIndex = weightOptions.firstIndex(of: viewModel.user.weightRecord.last?.weight ?? 0.0) ?? 0
            return PickerData(type: .weight, options: options, selectedIndex: selectedIndex)
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
        case .birthday:
            let selectedYear = yearOptions[selectedYearIndex]
            let selectedMonth = monthOptions[selectedMonthIndex]
            let selectedDay = dayOptions[selectedDayIndex]
            let dateString = "\(selectedYear)-\(String(format: "%02d", selectedMonth))-\(String(format: "%02d", selectedDay))"
            self.viewModel.user.birthday = dateString
            uploadToFirebase(data: ["birthday": dateString])
        case .weight:
            let selectedWeight = weightOptions[selectedIndex]
            self.viewModel.user.weightRecord.append(WeightRecord(createdTime: Timestamp(date: Date()), weight: selectedWeight))
            let docRef = FirestoreEndpoint.users.ref.document(UserProfileViewModel.shared.user.id)
            FirebaseManager.shared.setData(
                ["weightRecord": self.viewModel.user.weightRecord],
                at: docRef,
                merge: true
            )
        case .activityLevel:
            self.viewModel.user.activity = ActivityLevel.allCases[selectedIndex]
            uploadToFirebase(data: ["activity": ActivityLevel.allCases[selectedIndex].rawValue])
        case .target:
            self.viewModel.user.target = Target.allCases[selectedIndex]
            uploadToFirebase(data: ["target": Target.allCases[selectedIndex].rawValue])
        }
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
    
    private func setupBirthdayPickerDefaults() {
        let birthdayString = viewModel.user.birthday
        
        let dateComponents = birthdayString.split(separator: "-")
        
        if dateComponents.count == 3 {
            if let year = Int(dateComponents[0]), let month = Int(dateComponents[1]), let day = Int(dateComponents[2]) {
                selectedYearIndex = yearOptions.firstIndex(of: year) ?? 0
                selectedMonthIndex = monthOptions.firstIndex(of: month) ?? 0
                selectedDayIndex = dayOptions.firstIndex(of: day) ?? 0
                
                updateDayOptions()
            }
        }
    }
    
    private func updateDayOptions() {
        let selectedYear = yearOptions[selectedYearIndex]
        let selectedMonth = monthOptions[selectedMonthIndex]
        
        let isLeapYear = (selectedYear % 4 == 0 && selectedYear % 100 != 0) || (selectedYear % 400 == 0)
        let daysInMonth: Int
        
        switch selectedMonth {
        case 1, 3, 5, 7, 8, 10, 12:
            daysInMonth = 31
        case 4, 6, 9, 11:
            daysInMonth = 30
        case 2:
            daysInMonth = isLeapYear ? 29 : 28
        default:
            daysInMonth = 30
        }
        
        dayOptions = Array(1...daysInMonth)
    }
}
