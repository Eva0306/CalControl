//
//  RecordTabBarController.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/11.
//

import UIKit

class RecordTabBarController: UITabBarController {
    
    var selectedMealType: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.backgroundColor = UIColor.background
        tabBar.layer.shadowColor = UIColor.gray.cgColor
        tabBar.layer.shadowOpacity = 0.3
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -1)
        tabBar.layer.shadowRadius = 5
        tabBar.layer.masksToBounds = false
        tabBar.layer.shadowPath = UIBezierPath(rect: tabBar.bounds).cgPath
        
        self.selectedIndex = 1
        
        if let tabItems = tabBar.items {
            for item in tabItems {
                item.image = nil
                item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -10)
            }
        }
        
        let appearance = UITabBarItem.appearance()
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18)
        ]
        
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18)
        ]
        
        appearance.setTitleTextAttributes(attributes, for: .normal)
        appearance.setTitleTextAttributes(selectedAttributes, for: .selected)
    }
}
