//
//  FirebaseManager.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/17.
//

import FirebaseFirestore
import FirebaseStorage
import Foundation

enum FirestoreEndpoint {
    case foodRecord
    case waterRecord
    case users

    var ref: CollectionReference {
        let firestore = Firestore.firestore()

        switch self {
        case .foodRecord:
            return firestore.collection("foodRecord")
        case .waterRecord:
            return firestore.collection("waterRecord")
        case .users:
            return firestore.collection("users")
        }
    }
}

enum FirestoreCondition {
    case isEqualTo
    case isGreaterThanOrEqualTo
    case isLessThanOrEqualTo
}

final class FirebaseManager {
    
    static let shared = FirebaseManager()
    
    // 通用的獲取 documents 方法，使用泛型
    func getDocuments<T: Decodable>(from collection: FirestoreEndpoint, completion: @escaping ([T]) -> Void) {
        collection.ref.getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            completion(self.parseDocuments(snapshot: snapshot, error: error))
        }
    }
    
    func getDocuments<T: Decodable>(
        from collection: FirestoreEndpoint,
        where conditions: [(String, FirestoreCondition, Any)],
        completion: @escaping ([T]) -> Void
    ) {
        var query: Query = collection.ref
        
        // 根據傳入的條件構建查詢
        for (field, condition, value) in conditions {
            switch condition {
            case .isEqualTo:
                query = query.whereField(field, isEqualTo: value)
            case .isGreaterThanOrEqualTo:
                query = query.whereField(field, isGreaterThanOrEqualTo: value)
            case .isLessThanOrEqualTo:
                query = query.whereField(field, isLessThanOrEqualTo: value)
            }
        }
        
        // 執行查詢並解析結果
        query.getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            completion(self.parseDocuments(snapshot: snapshot, error: error))
        }
    }

    // 通用的添加 document 方法，使用泛型
    func setData<T: Encodable>(_ data: T, at docRef: DocumentReference) {
        do {
            try docRef.setData(from: data)
        } catch {
            print("DEBUG: Error encoding \(data.self) data -", error.localizedDescription)
        }
    }

    // 創建新 document 的參考
    func newDocument(of collection: FirestoreEndpoint, documentID: String? = nil) -> DocumentReference {
        if let documentID = documentID {
            return collection.ref.document(documentID) // 使用傳入的 documentID
        } else {
            return collection.ref.document() // 自動生成新的 documentID
        }
    }
    
    // 解析獲取到的 documents，使用泛型解碼
    private func parseDocuments<T: Decodable>(snapshot: QuerySnapshot?, error: Error?) -> [T] {
        guard let snapshot = snapshot else {
            let errorMessage = error?.localizedDescription ?? ""
            print("DEBUG: Error fetching snapshot -", errorMessage)
            return []
        }

        var models: [T] = []
        snapshot.documents.forEach { document in
            do {
                let item = try document.data(as: T.self)
                models.append(item)
            } catch {
                print("DEBUG: Error decoding \(T.self) data -", error.localizedDescription)
            }
        }
        return models
    }
    
    // 通用的刪除 document 方法，根據 Document ID 刪除
    func deleteDocument(from collection: FirestoreEndpoint, documentID: String, completion: @escaping (Bool) -> Void) {
        let docRef = collection.ref.document(documentID)
        docRef.delete { error in
            if let error = error {
                print("DEBUG: Failed to delete document - \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    // 通用的更新 document 方法，根據 Document ID 更新某些欄位
    func updateDocument(from collection: FirestoreEndpoint, documentID: String, data: [String: Any], completion: @escaping (Bool) -> Void) {
        let docRef = collection.ref.document(documentID)
        docRef.updateData(data) { error in
            if let error = error {
                print("DEBUG: Failed to update document - \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func uploadImage(image: UIImage, completion: @escaping (URL?) -> Void) {
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }

        let storageRef = Storage.storage().reference().child("FoodRecordImages/\(UUID().uuidString).jpg")

        storageRef.putData(imageData, metadata: nil) { metadata, error in
            guard error == nil else {
                print("Failed to upload image: \(error!.localizedDescription)")
                completion(nil)
                return
            }

            storageRef.downloadURL { url, error in
                guard let downloadURL = url, error == nil else {
                    print("Failed to fetch imageUrl: \(error!.localizedDescription)")
                    completion(nil)
                    return
                }

                completion(downloadURL)
            }
        }
    }
    
    func updateTotalNutrition(userID: String, newNutrition: TotalNutrition) {
        let userRef = Firestore.firestore().collection("users").document(userID)
        
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                var totalNutrition = document.data()?["totalNutrition"] as? [[String: Any]] ?? []
                
                // 檢查是否已有當日資料，並更新或插入新資料
                if let index = totalNutrition.firstIndex(where: {
                    let timestamp = $0["createdTime"] as? Timestamp
                    return timestamp?.dateValue() == newNutrition.date.dateValue()
                }) {
                    // 更新當日資料
                    totalNutrition[index] = [
                        "createdTime": newNutrition.date,
                        "totalCalories": newNutrition.totalCalories,
                        "totalCarbs": newNutrition.totalCarbs,
                        "totalProtein": newNutrition.totalProtein,
                        "totalFats": newNutrition.totalFats
                    ]
                } else {
                    // 插入新資料，並保持最新 7 天的記錄
                    totalNutrition.append([
                        "createdTime": newNutrition.date,
                        "totalCalories": newNutrition.totalCalories,
                        "totalCarbs": newNutrition.totalCarbs,
                        "totalProtein": newNutrition.totalProtein,
                        "totalFats": newNutrition.totalFats
                    ])
                    if totalNutrition.count > 7 {
                        totalNutrition.removeFirst() // 移除最早的資料
                    }
                }
                
                userRef.updateData([
                    "totalNutrition": totalNutrition
                ])
            }
        }
    }
}
