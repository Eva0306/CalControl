//
//  DoubleExtension.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/16.
//

import Foundation

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
