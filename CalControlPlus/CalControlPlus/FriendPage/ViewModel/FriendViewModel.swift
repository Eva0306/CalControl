//
//  FriendViewModel.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/23.
//

import Combine
import FirebaseFirestore

class FriendViewModel: ObservableObject {
    @Published var friends: [Friend] = []
    @Published var blockFriends: [Friend] = []
    
    var firebaseManager: FirebaseManagerProtocol
    
    init(firebaseManager: FirebaseManagerProtocol = FirebaseManager.shared) {
        self.firebaseManager = firebaseManager
    }
    
    func fetchFriendData(userID: String = UserProfileViewModel.shared.user.id) {
        let condition = [
            FirestoreCondition(field: "id", comparison: .isEqualTo, value: userID)
        ]
        
        firebaseManager.getDocuments(from: .users, where: condition) { [weak self] (users: [User]) in
            guard let self = self, let user = users.first else {
                debugLog("No user data found")
                return
            }
            
            DispatchQueue.main.async {
                self.friends = user.friends?.filter { $0.status == "accepted" } ?? []
                self.blockFriends = user.friends?.filter { $0.status == "blocked" } ?? []
                debugLog("Successfully fetched friends and blocked friends.")
            }
        }
    }
    
    // MARK: - Add Friend
    func addFriend(_ viewController: UIViewController, with friendID: String) {
        guard let currentUserID = UserProfileViewModel.shared?.user.id else { return }

        fetchFriendDocument(friendID: friendID, viewController: viewController) { [weak self] document in
            guard let self = self, document != nil else { return }

            let timestamp = Timestamp(date: Date())
            let friendData: [String: Any] = [
                "userID": friendID,
                "addedAt": timestamp,
                "status": "accepted",
                "isFavorite": false
            ]
            
            self.addNewFriend(
                for: currentUserID,
                friendData: friendData,
                viewController: viewController,
                isCurrentUser: true
            ) { success in
                if success {
                    let currentUserData: [String: Any] = [
                        "userID": currentUserID,
                        "addedAt": timestamp,
                        "status": "accepted",
                        "isFavorite": false
                    ]

                    self.addNewFriend(
                        for: friendID,
                        friendData: currentUserData,
                        viewController: viewController,
                        isCurrentUser: false
                    ) { success in
                        if success {
                            showTemporaryAlert(on: viewController, message: "已成功添加好友", feedbackType: .success)
                            self.fetchFriendData()
                        }
                    }
                }
            }
        }
    }

    private func fetchFriendDocument(
        friendID: String,
        viewController: UIViewController,
        completion: @escaping (DocumentSnapshot?) -> Void
    ) {
        let usersCollection = FirestoreEndpoint.users.ref

        usersCollection.document(friendID).getDocument { document, error in
            if let error = error {
                debugLog("Error fetching friend document - \(error.localizedDescription)")
                showOKAlert(on: viewController, title: "錯誤", message: "發生錯誤，請稍後再試。")
                completion(nil)
                return
            }

            guard let document = document, document.exists else {
                debugLog("Friend ID does not exist")
                showOKAlert(on: viewController, title: "錯誤", message: "查無此 ID，請確認後再試。")
                completion(nil)
                return
            }

            completion(document)
        }
    }
    
    private func addNewFriend(
        for userID: String,
        friendData: [String: Any],
        viewController: UIViewController,
        isCurrentUser: Bool,
        completion: @escaping (Bool) -> Void
    ) {
        let collection = FirestoreEndpoint.users
        
        collection.ref.document(userID).getDocument { document, error in
            if let error = error {
                debugLog("Error picking Image: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists else {
                completion(false)
                return
            }
            
            var friends = document.data()?["friends"] as? [[String: Any]] ?? []
            
            if friends.contains(where: { $0["userID"] as? String == friendData["userID"] as? String }) {
                if isCurrentUser {
                    showTemporaryAlert(on: viewController, message: "該好友已存在", feedbackType: .error)
                }
                completion(false)
                return
            }
            
            friends.append(friendData)
            
            FirebaseManager.shared.updateDocument(
                from: collection,
                documentID: userID,
                data: ["friends": friends]
            ) { success in
                completion(success)
            }
        }
    }
}

// MARK: - Favorite Status
extension FriendViewModel {
    func toggleFavorite(for friend: Friend) {
        guard let index = friends.firstIndex(where: { $0.userID == friend.userID }) else { return }
        friends[index].isFavorite.toggle()
        friends.sort { $0.isFavorite && !$1.isFavorite }
        updateFriendList()
    }
    
    private func updateFriendList() {
        let docRef = FirestoreEndpoint.users.ref.document(UserProfileViewModel.shared.user.id)
        
        let combinedFriends = friends + blockFriends
        
        FirebaseManager.shared.setData(
            ["friends": combinedFriends],
            at: docRef,
            merge: true
        )
    }
}

// MARK: - Delete or Block Friend
extension FriendViewModel {
    func updateFriendStatus(friendID: String, status: String, completion: @escaping (Bool) -> Void) {
        if let index = friends.firstIndex(where: { $0.userID == friendID }) {
            friends[index].status = status
            updateFriendList()
            fetchFriendData()
            completion(true)
        } else {
            completion(false)
        }
    }
    
    func updateFriendStatusFromFriend(friendID: String, status: String, completion: @escaping (Bool) -> Void) {
        let userRef = FirestoreEndpoint.users.ref.document(friendID)
        let currentUserID = UserProfileViewModel.shared.user.id
        
        userRef.getDocument { document, error in
            if let error = error {
                debugLog("Error update friend status - \(error.localizedDescription)")
            }
            
            guard let document = document, document.exists else {
                debugLog("Failed to fetch remote user data.")
                completion(false)
                return
            }
            
            let data = document.data() ?? [:]
            var friends = data["friends"] as? [[String: Any]] ?? []
            
            if let index = friends.firstIndex(where: { $0["userID"] as? String == currentUserID }) {
                friends[index]["status"] = status
            } else {
                debugLog("Current user not found in the friend's list")
                completion(false)
                return
            }
            
            FirebaseManager.shared.updateDocument(
                from: .users,
                documentID: friendID,
                data: ["friends": friends]
            ) { success in
                if success {
                    debugLog("Successfully updated friend's status on remote")
                } else {
                    debugLog("Failed to update friend's status on remote")
                }
                completion(success)
            }
        }
    }
    
    func removeFriend(friendID: String, completion: @escaping () -> Void) {
        friends.removeAll { $0.userID == friendID }
        blockFriends.removeAll { $0.userID == friendID }
        
        updateFriendList()
        completion()
    }
    
    func removeCurrentUserFromFriend(friendID: String, completion: @escaping (Bool) -> Void) {
        let currentUserID = UserProfileViewModel.shared.user.id
        let friendDocRef = FirestoreEndpoint.users.ref.document(friendID)
        
        friendDocRef.getDocument { document, error in
            guard let document = document, document.exists, var data = document.data() else {
                debugLog("Failed to fetch friend's document.")
                completion(false)
                return
            }
            
            var friends = data["friends"] as? [[String: Any]] ?? []
            friends.removeAll { $0["userID"] as? String == currentUserID }
            
            data["friends"] = friends
            friendDocRef.setData(data) { error in
                if let error = error {
                    debugLog("Failed to update friend's document: \(error.localizedDescription)")
                    completion(false)
                } else {
                    debugLog("Successfully deleted current user from friend's list.")
                    completion(true)
                }
            }
        }
    }
}
