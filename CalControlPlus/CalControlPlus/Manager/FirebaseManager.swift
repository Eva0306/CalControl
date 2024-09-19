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

    var ref: CollectionReference {
        let firestore = Firestore.firestore()

        switch self {
        case .foodRecord:
            return firestore.collection("foodRecord")
        case .waterRecord:
            return firestore.collection("waterRecord")
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
    
    func getDocuments<T: Decodable>(from collection: FirestoreEndpoint, where field: String, isEqualTo value: Any, completion: @escaping ([T]) -> Void) {
        collection.ref.whereField(field, isEqualTo: value).getDocuments { [weak self] snapshot, error in
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
}
