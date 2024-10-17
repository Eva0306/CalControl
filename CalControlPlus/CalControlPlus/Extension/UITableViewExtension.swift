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
    
    func dequeueReusableCell<T: UITableViewCell>(withIdentifier identifier: String, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T else {
            fatalError("Unable to dequeue cell with identifier: \(identifier)")
        }
        return cell
    }
}
