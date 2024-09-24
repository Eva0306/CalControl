//
//  UIViewExtension.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/24.
//

import UIKit

extension UIView {
    func findViewController() -> UIViewController? {
        var nextResponder: UIResponder? = self
        while nextResponder != nil {
            nextResponder = nextResponder?.next
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
