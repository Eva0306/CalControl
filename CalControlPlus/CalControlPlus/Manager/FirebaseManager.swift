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

struct FirestoreCondition {
    let field: String
    let comparison: FirestoreComparison
    let value: Any
}

enum FirestoreComparison {
    case isEqualTo
    case isGreaterThanOrEqualTo
    case isLessThanOrEqualTo
}

enum DocumentChangeType {
    case added
    case modified
    case removed
}

enum StorageFolder {
    case FoodRecordImages
    case UserAvatarImages
    
    var ref: StorageReference {
        let fireStorage = Storage.storage().reference()
        switch self {
        case .FoodRecordImages:
            return fireStorage.child("FoodRecordImages/\(UUID().uuidString).jpg")
        case .UserAvatarImages:
            return fireStorage.child("UserAvatarImages/\(UUID().uuidString).jpg")
        }
    }
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
    
    // 依搜尋條件獲取 documents
    func getDocuments<T: Decodable>(
        from collection: FirestoreEndpoint,
        where conditions: [FirestoreCondition],
        completion: @escaping ([T]) -> Void
    ) {
        var query: Query = collection.ref
        
        for condition in conditions {
            switch condition.comparison {
            case .isEqualTo:
                query = query.whereField(condition.field, isEqualTo: condition.value)
            case .isGreaterThanOrEqualTo:
                query = query.whereField(condition.field, isGreaterThanOrEqualTo: condition.value)
            case .isLessThanOrEqualTo:
                query = query.whereField(condition.field, isLessThanOrEqualTo: condition.value)
            }
        }
        
        query.getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            completion(self.parseDocuments(snapshot: snapshot, error: error))
        }
    }
    
    func getDocument<T: Decodable>(from collection: FirestoreEndpoint, documentID: String, completion: @escaping (T?) -> Void) {
        let docRef = collection.ref.document(documentID)
        
        docRef.getDocument { document, error in
            if let document = document, document.exists {
                do {
                    let item = try document.data(as: T.self)
                    completion(item)
                } catch {
                    print("DEBUG: Error decoding \(T.self) data -", error.localizedDescription)
                    completion(nil)
                }
            } else {
                print("DEBUG: Document does not exist or error occurred -", error?.localizedDescription ?? "")
                completion(nil)
            }
        }
    }

    // 通用的添加 document 方法，使用泛型
    func setData<T: Encodable>(_ data: T, at docRef: DocumentReference, merge: Bool = false) {
        do {
            try docRef.setData(from: data, merge: merge)
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
    
    // DOING
    func evaPrint(_ str: String) {
        #if DEBUG
            
        #endif
    }
    
    // 通用的更新 document 方法，根據 Document ID 更新某些欄位
    func updateDocument(
        from collection: FirestoreEndpoint,
        documentID: String, data: [String: Any],
        completion: @escaping (Bool) -> Void
    ) {
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
    
    func updateDocument(
        from collection: FirestoreEndpoint,
        documentID: String, data: [String: Any],
        merge: Bool = false,
        completion: @escaping (Bool) -> Void
    ) {
        let ref = collection.ref.document(documentID)
        ref.setData(data, merge: merge) { error in
            if let error = error {
                print("Error updating document: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func uploadImage(image: UIImage, folder: StorageFolder, completion: @escaping (URL?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }
        let storageRef = folder.ref
        storageRef.putData(imageData, metadata: nil) { _, error in
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
    
    func addObserver<T: Decodable>(
        on collection: FirestoreEndpoint,
        where conditions: [FirestoreCondition],
        completion: @escaping (_ changeType: DocumentChangeType, _ data: T) -> Void
    ) {
        var query: Query = collection.ref
        
        for condition in conditions {
            switch condition.comparison {
            case .isEqualTo:
                query = query.whereField(condition.field, isEqualTo: condition.value)
            case .isGreaterThanOrEqualTo:
                query = query.whereField(condition.field, isGreaterThanOrEqualTo: condition.value)
            case .isLessThanOrEqualTo:
                query = query.whereField(condition.field, isLessThanOrEqualTo: condition.value)
            }
        }
        
        // 註冊監聽器，並保存它以便稍後可以移除
        let listener = query.addSnapshotListener { (snapshot, error) in
            if let error = error {
                print("Error listening to changes in \(collection): \(error.localizedDescription)")
                return
            }
            
            guard let snapshot = snapshot else { return }
            
            snapshot.documentChanges.forEach { change in
                do {
                    let item = try change.document.data(as: T.self)
                    switch change.type {
                    case .added:
                        completion(.added, item)
                    case .modified:
                        completion(.modified, item)
                    case .removed:
                        completion(.removed, item)
                    }
                } catch {
                    print("Error decoding document as \(T.self): \(error.localizedDescription)")
                }
            }
        }
        
        // 保存監聽器
        listeners[collection] = listener
    }

    private var listeners: [FirestoreEndpoint: ListenerRegistration] = [:]
    
    func removeObservers(on collection: FirestoreEndpoint) {
        // 檢查並移除該集合的監聽器
        if let listener = listeners[collection] {
            listener.remove()
            listeners[collection] = nil
        }
    }
    
}
