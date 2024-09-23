//
//  FriendCardViewModel.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/23.
//

import Foundation

class FriendCardViewModel: ObservableObject {
    @Published var friendName: String = "Friend name"
    @Published var avatarUrl: String? = nil
    @Published var calProgress: Double = 0.0
    @Published var carbsProgress: Double = 0.7
    @Published var fatsProgress: Double = 0.5
    @Published var proteinProgress: Double = 0.6
    
    var friend: User?

    func fetchFriendData(friendID: String) {
        
        FirebaseManager.shared.getDocuments(
            from: .users,
            where: [("id", .isEqualTo, friendID)]
        ) { [weak self] (users: [User]) in
            guard let self = self else { return }
            
            if let user = users.first {
                let friend = user
                self.friend = friend
                updateCard()
            }
        }
    }
    
    func updateCard() {
        guard let friend = self.friend else { return }
        let userSettings = UserSettingsCalculator().setupUserSettings(user: friend)
        self.friendName = friend.name
        self.avatarUrl = friend.avatarUrl
        if let data = friend.totalNutrition.last {
            self.calProgress = data.totalCalories / Double(userSettings.basicGoal)
            self.carbsProgress = data.totalCarbs / userSettings.carbohydrateTotal
            self.fatsProgress = data.totalFats / userSettings.fatTotal
            self.proteinProgress = data.totalProtein / userSettings.proteinTotal
        }
    }
}
