//
//  FirebaseManager.swift
//  CalControl+
//
//  Created by 楊芮瑊 on 2024/9/17.
//

import FirebaseFirestore
import Foundation

enum FirestoreEndpoint {
    case foodRecord

    var ref: CollectionReference {
        let firestore = Firestore.firestore()

        switch self {
        case .foodRecord:
            return firestore.collection("foodRecord")
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

    // 通用的添加 document 方法，使用泛型
    func setData<T: Encodable>(_ data: T, at docRef: DocumentReference) {
        do {
            try docRef.setData(from: data)
        } catch {
            print("DEBUG: Error encoding \(data.self) data -", error.localizedDescription)
        }
    }

    // 創建新 document 的參考
    func newDocument(of collection: FirestoreEndpoint) -> DocumentReference {
        collection.ref.document()
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
}
