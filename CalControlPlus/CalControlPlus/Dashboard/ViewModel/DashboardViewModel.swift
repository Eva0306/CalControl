//
//  DashboardViewModel.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/19.
//

import Foundation

class DashboardViewModel: ObservableObject {
    
    @Published var foodRecords: [FoodRecord] = []
    
    let userProfileViewModel: UserProfileViewModel
    
    init(userProfileViewModel: UserProfileViewModel) {
        self.userProfileViewModel = userProfileViewModel
    }
    
}
