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
        let userRef = FirestoreEndpoint.users.ref.document(UserProfileViewModel.shared.user.id)
        
        userRef.getDocument { [weak self] document, error in
            guard let self = self else { return }
            
            guard let document = document, document.exists, let data = document.data() else {
                print("DEBUG: Failed to fetch document - \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let friendsData = data["friends"] as? [[String: Any]] {
                let friendsList = self.parseFriends(from: friendsData)
                
                DispatchQueue.main.async {
                    self.friends = friendsList
                    print("DEBUG: Successfully fetched friends")
                }
            } else {
                print("DEBUG: No friends data found")
            }
        }
    }
    
    func addObserver() {
        let condition = [
            FirestoreCondition(field: "user", comparison: .isEqualTo, value: UserProfileViewModel.shared.user.id)
        ]
        FirebaseManager.shared.addObserver(
            on: .users,
            where: condition
        ) { [weak self] (_: DocumentChangeType, _: FoodRecord) in
            guard let self = self else { return }
            self.fetchFriendData()
        }
    }
    
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
                "status": "accepted"
            ]
            
            self?.updateFriendsList(for: currentUserID, friendData: friendData) { success in
                if success {
                    let currentUserData: [String: Any] = [
                        "userID": currentUserID,
                        "addedAt": timestamp,
                        "status": "accepted"
                    ]
                    
                    self?.updateFriendsList(for: friendID, friendData: currentUserData) { success in
                        if success {
                            print("DEBUG: Successfully added friend both ways")
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
    
    private func updateFriendsList(
        for userID: String,
        friendData: [String: Any],
        completion: @escaping (Bool) -> Void
    ) {
        let collection = FirestoreEndpoint.users
        
        collection.ref.document(userID).getDocument { document, error in
            guard let document = document, document.exists else {
                print("DEBUG: Failed to fetch document - \(error?.localizedDescription ?? "Unknown error")")
                completion(false)
                return
            }
            
            let data = document.data() ?? [:]
            var friends = data["friends"] as? [[String: Any]] ?? []
            
            if !friends.contains(where: { $0["userID"] as? String == friendData["userID"] as? String }) {
                print("DEBUG: Adding friend: \(friendData)")
                friends.append(friendData)
            } else {
                print("DEBUG: Friend already exists")
                completion(true)
                return
            }
            
            FirebaseManager.shared.updateDocument(
                from: collection,
                documentID: userID,
                data: ["friends": friends]
            ) { success in
                if success {
                    print("DEBUG: Successfully updated friends list for user: \(userID)")
                } else {
                    print("DEBUG: Failed to update friends list for user: \(userID)")
                }
                completion(success)
            }
        }
    }

    private func parseFriends(from friendsData: [[String: Any]]) -> [Friend] {
        var friendsList: [Friend] = []
        
        for friendDict in friendsData {
            guard
                let userID = friendDict["userID"] as? String,
                let addedAt = friendDict["addedAt"] as? Timestamp,
                let status = friendDict["status"] as? String
            else {
                print("DEBUG: Invalid friend data format")
                continue
            }
            
            let friend = Friend(userID: userID, addedAt: addedAt, status: status)
            friendsList.append(friend)
        }
        
        return friendsList
    }
}
