//
//  MainTabBarController.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/11.
//

import UIKit
import Lottie

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    private var plusButtonAnimationView: LottieAnimationView = {
        let animationView = LottieAnimationView(name: "PlusToXAnimation")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.translatesAutoresizingMaskIntoConstraints = false
        return animationView
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.delegate = self
        
        tabBar.backgroundColor = .white.withAlphaComponent(0.8)
        
        tabBar.layer.shadowColor = UIColor.gray.cgColor
        tabBar.layer.shadowOpacity = 0.3
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -1)
        tabBar.layer.shadowRadius = 5
        tabBar.layer.masksToBounds = false
        tabBar.layer.shadowPath = UIBezierPath(rect: tabBar.bounds).cgPath
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        guard let viewControllers = tabBarController.viewControllers,
              let index = viewControllers.firstIndex(of: viewController) else {
            return true
        }
        
        if index == 2 {
            
            let mealSelectionVC = MealSelectionVC()
            mealSelectionVC.modalPresentationStyle = .overFullScreen
            mealSelectionVC.onMealSelected = { [weak self] selectedMeal in
                self?.showRecordTabBar(for: selectedMeal)
            }
            present(mealSelectionVC, animated: true, completion: nil)
            return false
        }
        
        return true
    }
    
    private func showRecordTabBar(for mealType: Int) {
        let storyboard = UIStoryboard(name: "DietRecord", bundle: nil)
        if let popupTabBarController = storyboard.instantiateViewController(withIdentifier: "RecordTabBarController") as? RecordTabBarController {
            popupTabBarController.modalPresentationStyle = .fullScreen
            popupTabBarController.selectedMealType = mealType
            present(popupTabBarController, animated: true, completion: nil)
            
        } else {
            print("Cannot Find RecordTabBarController")
        }
    }
}
