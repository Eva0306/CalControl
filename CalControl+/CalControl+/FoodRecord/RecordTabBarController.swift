//
//  RecordTabBarController.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/11.
//

import UIKit

class RecordTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.backgroundColor = UIColor.background
        
        self.selectedIndex = 1
        
        if let tabItems = tabBar.items {
            for item in tabItems {
                item.image = nil
                item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -10)
            }
        }
        
        let appearance = UITabBarItem.appearance()
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18),
        ]
        
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
        ]
        
        appearance.setTitleTextAttributes(attributes, for: .normal)
        appearance.setTitleTextAttributes(selectedAttributes, for: .selected)
    }
}
