//
//  MainTabBarController.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/11.
//

import UIKit
import Lottie

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    private var isAddButtonExpanded = false
    private var plusButtonAnimationView: LottieAnimationView = {
        let animationView = LottieAnimationView(name: "PlusToXAnimation")
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .playOnce
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.layer.shadowColor = UIColor.black.cgColor
        animationView.layer.shadowOpacity = 0.3
        animationView.layer.shadowOffset = CGSize(width: 0, height: 3)
        animationView.layer.shadowRadius = 5
        return animationView
    }()
    
    private lazy var mealButtons: [UIStackView] = {
        let titles = ["早餐", "午餐", "晚餐", "點心"]
        let images = [
            UIImage(named: "breakfast"),
            UIImage(named: "lunch"),
            UIImage(named: "dinner"),
            UIImage(named: "snack")
        ]
        
        return titles.enumerated().map { index, title in
            return createMealButton(withTitle: title, image: images[index], tag: index)
        }
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: mealButtons)
        sv.axis = .horizontal
        sv.alignment = .center
        sv.spacing = 20
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        customizeTabBarAppearance()
        setupDimmingView()
        setupAddButton()
        setupMealButtons()
    }
    
    private func setupAddButton() {
        view.addSubview(plusButtonAnimationView)
        NSLayoutConstraint.activate([
            plusButtonAnimationView.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor),
            plusButtonAnimationView.centerYAnchor.constraint(equalTo: tabBar.topAnchor, constant: 15),
            plusButtonAnimationView.widthAnchor.constraint(equalToConstant: 70),
            plusButtonAnimationView.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addNewRecord))
        plusButtonAnimationView.addGestureRecognizer(tapGesture)
        plusButtonAnimationView.isUserInteractionEnabled = true
    }
    
    private func setupDimmingView() {
        view.addSubview(dimmingView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeMealButtons))
        dimmingView.addGestureRecognizer(tapGesture)
        
        NSLayoutConstraint.activate([
            dimmingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimmingView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupMealButtons() {
        view.addSubview(buttonStackView)
        view.bringSubviewToFront(plusButtonAnimationView)
        
        NSLayoutConstraint.activate([
            buttonStackView.centerXAnchor.constraint(equalTo: plusButtonAnimationView.centerXAnchor),
            buttonStackView.centerYAnchor.constraint(equalTo: plusButtonAnimationView.centerYAnchor, constant: -100)
        ])
    }
    
    private func createMealButton(withTitle title: String, image: UIImage?, tag: Int) -> UIStackView {
        let button = UIButton(type: .system)
        if let resizedImage = image?.resize(to: CGSize(width: 40, height: 40)) {
            button.setImage(resizedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        button.imageView?.contentMode = .scaleAspectFit
        button.backgroundColor = .cellBackground
        button.tintColor = .clear
        button.layer.cornerRadius = 35
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 70).isActive = true
        button.heightAnchor.constraint(equalToConstant: 70).isActive = true
        button.tag = tag
        button.addTarget(self, action: #selector(mealButtonTapped(_:)), for: .touchUpInside)
        
        let label = UILabel()
        label.text = title
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [button, label])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alpha = 0
        
        return stackView
    }
    
    private func customizeTabBarAppearance() {
        tabBar.backgroundColor = .cellBackground.withAlphaComponent(0.8)
        
        tabBar.layer.shadowColor = UIColor.gray.cgColor
        tabBar.layer.shadowOpacity = 0.3
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -1)
        tabBar.layer.shadowRadius = 5
        tabBar.layer.masksToBounds = false
        tabBar.layer.shadowPath = UIBezierPath(rect: tabBar.bounds).cgPath
    }
    
    @objc private func addNewRecord() {
        if isAddButtonExpanded {
            closeMealButtons()
        } else {
            expandMealButtons()
        }
    }
    
    private func expandMealButtons() {
        plusButtonAnimationView.play(fromProgress: 0.0, toProgress: 0.065) { [weak self] _ in
            self?.isAddButtonExpanded = true
        }
        
        animateMealButtons(shouldExpand: true)
        
        UIView.animate(withDuration: 0.3) {
            self.dimmingView.alpha = 1.0
        }
    }
    
    @objc private func closeMealButtons() {
        plusButtonAnimationView.play(fromProgress: 0.065, toProgress: 0.0) { [weak self] _ in
            self?.isAddButtonExpanded = false
        }
        animateMealButtons(shouldExpand: false)
        
        UIView.animate(withDuration: 0.3) {
            self.dimmingView.alpha = 0
        }
    }
    
    private func animateMealButtons(shouldExpand: Bool) {
        let duration: TimeInterval = 0.3
        let alpha: CGFloat = shouldExpand ? 1.0 : 0.0
        
        if shouldExpand {
            mealButtons.forEach { button in
                let originalPosition = buttonStackView.convert(button.center, to: view)
                let plusButtonPosition = plusButtonAnimationView.center
                let translationX = plusButtonPosition.x - originalPosition.x
                let translationY = plusButtonPosition.y - originalPosition.y
                
                button.transform = CGAffineTransform(translationX: translationX, y: translationY)
                button.alpha = 0.0
            }
        }
        
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseInOut, animations: {
            self.mealButtons.forEach { stackView in
                if shouldExpand {
                    stackView.transform = .identity
                    stackView.alpha = alpha
                } else {
                    let originalPosition = self.buttonStackView.convert(stackView.center, to: self.view)
                    let plusButtonPosition = self.plusButtonAnimationView.center
                    let translationX = plusButtonPosition.x - originalPosition.x
                    let translationY = plusButtonPosition.y - originalPosition.y
                    
                    stackView.transform = CGAffineTransform(translationX: translationX, y: translationY)
                    stackView.alpha = alpha
                }
            }
        }, completion: nil)
    }
    
    @objc private func mealButtonTapped(_ sender: UIButton) {
        closeMealButtons()
        showRecordTabBar(for: sender.tag)
    }
    
    func tabBarController(
        _ tabBarController: UITabBarController,
        shouldSelect viewController: UIViewController
    ) -> Bool {
        guard let viewControllers = tabBarController.viewControllers,
              let index = viewControllers.firstIndex(of: viewController) else {
            return true
        }
        if index == 2 {
            return false
        }
        return true
    }
    
    private func showRecordTabBar(for mealType: Int) {
        let storyboard = UIStoryboard(name: "DietRecord", bundle: nil)
        if let popupTabBarController = storyboard.instantiateViewController(
            withIdentifier: "RecordTabBarController"
        ) as? RecordTabBarController {
            popupTabBarController.modalPresentationStyle = .fullScreen
            popupTabBarController.selectedMealType = mealType
            present(popupTabBarController, animated: true, completion: nil)
        } else {
            debugLog("Cannot Find RecordTabBarController")
        }
    }
}
