//
//  FriendCardViewModel.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/23.
//

import Foundation

class FriendCardViewModel: ObservableObject {
    @Published var friendName: String = ""
    @Published var avatarUrl: String?
    @Published var calProgress: Double = 0.0
    @Published var carbsProgress: Double = 0.7
    @Published var fatsProgress: Double = 0.5
    @Published var proteinProgress: Double = 0.6
    
    var friend: User?
    
    var didToggleFavorite: (() -> Void)?

    func fetchFriendData(friendID: String) {
        let condition = [FirestoreCondition(field: "id", comparison: .isEqualTo, value: friendID)]
        
        FirebaseManager.shared.getDocuments(
            from: .users,
            where: condition
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

        let calendar = Calendar.current
        let todayMidnight = Calendar.current.startOfDay(for: Date())

        if let todayData = friend.totalNutrition.first(
            where: { calendar.startOfDay(for: $0.date.dateValue()) == todayMidnight }
        ) {
            self.calProgress = todayData.totalCalories / Double(userSettings.basicGoal)
            self.carbsProgress = todayData.totalCarbs / userSettings.carbohydrateTotal
            self.fatsProgress = todayData.totalFats / userSettings.fatTotal
            self.proteinProgress = todayData.totalProtein / userSettings.proteinTotal
        } else {
            self.calProgress = 0
            self.carbsProgress = 0
            self.fatsProgress = 0
            self.proteinProgress = 0
        }
    }
    
    func toggleFavoriteStatus() {
        didToggleFavorite?()
    }
}
