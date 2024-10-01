//
//  PickerModel.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/24.
//

import Foundation

enum PickerType: CaseIterable {
    case gender
    case height
    case activityLevel
    case target
}

struct PickerData {
    let type: PickerType
    var options: [String]
    var selectedIndex: Int
}
