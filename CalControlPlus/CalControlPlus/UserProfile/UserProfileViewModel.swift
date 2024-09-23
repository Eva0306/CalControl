//
//  UserProfileViewModel.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/20.
//

import Foundation

struct BasicGoal {
    var calories: Int
    var proteinPercentage: Double
    var carbPercentage: Double
    var fatPercentage: Double
}

class UserProfileViewModel: ObservableObject {
    
    static var shared: UserProfileViewModel!
    
    @Published var userSettings: UserSettings!
    @Published var user: User
    
    init(user: User) {
        self.user = user
        
        self.userSettings = UserSettingsCalculator().setupUserSettings(user: user)
    }
    
}
