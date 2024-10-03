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
    
    func fetchFriendData() {
        let condition = [
            FirestoreCondition(field: "id", comparison: .isEqualTo, value: UserProfileViewModel.shared.user.id)
        ]
        
        FirebaseManager.shared.getDocuments(from: .users, where: condition) { (users: [User]) in
            guard let user = users.first else {
                print("DEBUG: No user data found")
                return
            }
            
            if let friendsList = user.friends?.filter({ $0.status == "accepted" }) {
                DispatchQueue.main.async { [weak self] in
                    self?.friends = friendsList
                    print("DEBUG: Successfully fetched accepted friends")
                }
            } else {
                print("DEBUG: No accepted friends found for user")
            }
        }
    }
    
//    func addObserver() {
//        let condition = [
//            FirestoreCondition(field: "user", comparison: .isEqualTo, value: UserProfileViewModel.shared.user.id)
//        ]
//        FirebaseManager.shared.addObserver(
//            on: .users,
//            where: condition
//        ) { [weak self] (_: DocumentChangeType, _: FoodRecord) in
//            guard let self = self else { return }
//            self.fetchFriendData()
//        }
//    }
    
    func addFriend(_ viewController: UIViewController, with friendID: String) {
        guard let currentUserID = UserProfileViewModel.shared?.user.id else { return }
        
        let usersCollection = FirestoreEndpoint.users.ref
        
        usersCollection.document(friendID).getDocument { [weak self] document, error in
            if let error = error {
                print("DEBUG: Error fetching friend document - \(error.localizedDescription)")
                self?.showAlert(in: viewController, message: "發生錯誤，請稍後再試。")
                return
            }
            
            guard let document = document, document.exists else {
                print("DEBUG: Friend ID does not exist")
                self?.showAlert(in: viewController, message: "查無此 ID，請確認後再試。")
                return
            }
            
            let timestamp = Timestamp(date: Date())
            
            let friendData: [String: Any] = [
                "userID": friendID,
                "addedAt": timestamp,
                "status": "accepted",
                "isFavorite": false
            ]
            
            self?.addNewFriend(for: currentUserID, friendData: friendData, viewController: viewController) { success in
                if success {
                    let currentUserData: [String: Any] = [
                        "userID": currentUserID,
                        "addedAt": timestamp,
                        "status": "accepted",
                        "isFavorite": false
                    ]
                    
                    self?.addNewFriend(
                        for: friendID,
                        friendData: currentUserData,
                        viewController: viewController
                    ) { success in
                        if success {
                            print("DEBUG: Successfully added friend both ways")
                            self?.showTemporaryAlert(
                                in: viewController,
                                message: "已成功添加好友"
                            )
                            self?.fetchFriendData()
                        }
                    }
                } else {
                    print("DEBUG: Failed to add friend")
                }
            }
        }
    }
    
    private func showAlert(in viewController: UIViewController, message: String) {
        let alert = UIAlertController(title: "錯誤", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default, handler: nil)
        alert.addAction(okAction)
        
        DispatchQueue.main.async {
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    private func showTemporaryAlert(in viewController: UIViewController,message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        viewController.present(alertController, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            alertController.dismiss(animated: true, completion: nil)
        }
    }
    
    private func addNewFriend(
        for userID: String,
        friendData: [String: Any],
        viewController: UIViewController,
        completion: @escaping (Bool) -> Void
    ) {
        let collection = FirestoreEndpoint.users
        
        collection.ref.document(userID).getDocument { document, error in
            guard let document = document, document.exists else {
                print("DEBUG: Failed to fetch document - \(error?.localizedDescription ?? "Unknown error")")
                completion(false)
                return
            }
            
            var friends = document.data()?["friends"] as? [[String: Any]] ?? []
            
            if friends.contains(where: { $0["userID"] as? String == friendData["userID"] as? String }) {
                print("DEBUG: Friend already exists")
                self.showTemporaryAlert(in: viewController, message: "該好友已存在")
                completion(false)
                return
            }
            
            print("DEBUG: Adding new friend: \(friendData)")
            friends.append(friendData)
            
            FirebaseManager.shared.updateDocument(
                from: collection,
                documentID: userID,
                data: ["friends": friends]
            ) { success in
                if success {
                    print("DEBUG: Successfully added new friend for user: \(userID)")
                } else {
                    print("DEBUG: Failed to add new friend for user: \(userID)")
                }
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
        FirebaseManager.shared.setData(
            ["friends": self.friends],
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
            completion(true)
        } else {
            completion(false)
        }
    }
    
    func updateFriendStatusOnRemote(friendID: String, status: String, completion: @escaping (Bool) -> Void) {
        let userRef = FirestoreEndpoint.users.ref.document(friendID)
        let currentUserID = UserProfileViewModel.shared.user.id
        
        userRef.getDocument { document, error in
            guard let document = document, document.exists else {
                print("Failed to fetch remote user data.")
                completion(false)
                return
            }
            
            var data = document.data() ?? [:]
            var friends = data["friends"] as? [[String: Any]] ?? []
            
            if let index = friends.firstIndex(where: { $0["userID"] as? String == currentUserID }) {
                friends[index]["status"] = status
            } else {
                print("Current user not found in the friend's list")
                completion(false)
                return
            }
            
            FirebaseManager.shared.updateDocument(
                from: .users,
                documentID: friendID,
                data: ["friends": friends]
            ) { success in
                if success {
                    print("Successfully updated friend's status on remote")
                } else {
                    print("Failed to update friend's status on remote")
                }
                completion(success)
            }
        }
    }

    func removeFriend(friendID: String, completion: @escaping (Bool) -> Void) {
        friends.removeAll { $0.userID == friendID }
        updateFriendList()
    }
}
