//
//  UIImageViewExtension.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/19.
//

import UIKit
import Kingfisher

extension UIImageView {
    func loadImage(with url: String) {
        self.kf.setImage(with: URL(string: url))
    }
}
