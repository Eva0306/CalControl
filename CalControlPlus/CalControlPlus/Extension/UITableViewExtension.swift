//
//  UITableViewExtension.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/25.
//

import UIKit

extension UITableView {
    func visibleRect() -> CGRect {
        return CGRect(x: contentOffset.x, y: contentOffset.y, width: bounds.width, height: bounds.height)
    }
}
