//
//  WaterRecordModel.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/18.
//

import Foundation
import FirebaseFirestore

struct WaterRecord: Codable {
    let id: String
    let userID: String
    let date: Timestamp
    var totalWaterIntake: Int
}
