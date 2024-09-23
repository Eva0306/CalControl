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
    
    func addFriend(with friendID: String) {
        print("Ready to add")
        guard let currentUserID = UserProfileViewModel.shared?.user.id else { return }
        
        let timestamp = Timestamp(date: Date())
        
        let friendData: [String: Any] = [
            "userID": friendID,
            "addedAt": timestamp,
            "status": "accepted"
        ]
        
        // 更新自己和朋友的好友列表
        updateFriendsList(for: currentUserID, friendData: friendData) { [weak self] success in
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
            }
        }
    }
    
    private func updateFriendsList(
        for userID: String,
        friendData: [String: Any],
        completion: @escaping (Bool) -> Void
    ) {
        let collection = FirestoreEndpoint.users
        
        // 獲取文件
        collection.ref.document(userID).getDocument { document, error in
            guard let document = document, document.exists else {
                print("DEBUG: Failed to fetch document - \(error?.localizedDescription ?? "Unknown error")")
                completion(false)
                return
            }
            
            let data = document.data() ?? [:]
            var friends = data["friends"] as? [[String: Any]] ?? []
            
            // 檢查是否已經存在這個好友
            if !friends.contains(where: { $0["userID"] as? String == friendData["userID"] as? String }) {
                print("DEBUG: Adding friend: \(friendData)") // Debug print
                friends.append(friendData)
            } else {
                print("DEBUG: Friend already exists")
                completion(true)
                return
            }
            
            // 更新文檔
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

    // Helper function to parse friend data
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
