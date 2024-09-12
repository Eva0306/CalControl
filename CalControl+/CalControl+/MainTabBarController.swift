//
//  MainTabBarController.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/11.
//

import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.delegate = self
        
        tabBar.backgroundColor = .white.withAlphaComponent(0.8)
        
        tabBar.layer.shadowColor = UIColor.gray.cgColor
        tabBar.layer.shadowOpacity = 0.3
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -1)
        tabBar.layer.shadowRadius = 5
        tabBar.layer.masksToBounds = false
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        guard let viewControllers = tabBarController.viewControllers,
              let index = viewControllers.firstIndex(of: viewController) else {
            return
        }
        
        if index == 2 {
            
            let storyboard = UIStoryboard(name: "DietRecord", bundle: nil)
            
            if let popupTabBarController = storyboard.instantiateViewController(withIdentifier: "RecordTabBarController") as? RecordTabBarController {
                
                popupTabBarController.modalPresentationStyle = .fullScreen
                present(popupTabBarController, animated: true, completion: nil)
                
            } else {
                
                print("Cannot Find RecordTabBarController")
            }
        }
    }
}
