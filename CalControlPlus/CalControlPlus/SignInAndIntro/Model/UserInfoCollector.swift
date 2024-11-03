//
//  UserInfoCollector.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/28.
//

import UIKit
import FirebaseCore

class UserInfoCollector {
    
    static let shared = UserInfoCollector()
    
    var userID: String?
    var name: String?
    var email: String?
    var avatarImage: UIImage?
    var gender: Gender?
    var birthday: String?
    var height: Double?
    var weight: Double?
    var activity: ActivityLevel?
    var target: Target?
    
    func createUser() -> User? {
        guard let userID = userID,
              let name = name,
              let gender = gender,
              let birthday = birthday,
              let height = height,
              let weight = weight,
              let activity = activity,
              let target = target else {
            return nil
        }
        
        return User(
            id: userID,
            status: .active,
            createdTime: Timestamp(date: Date()),
            email: email,
            name: name,
            avatarUrl: nil,
            gender: gender,
            birthday: birthday,
            height: height,
            weightRecord: [WeightRecord(date: Timestamp(date: Date()), weight: weight)],
            activity: activity,
            target: target,
            totalNutrition: []
        )
    }
}
