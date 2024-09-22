//
//  WeightRecordViewModel.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/23.
//

import Combine
import FirebaseCore

class WeightRecordViewModel: ObservableObject {
    @Published var weightRecords: [WeightRecord] = []
    
    func fetchWeightRecord() {
        FirebaseManager.shared.getDocuments(
            from: .users,
            where: [("id", .isEqualTo, UserProfileViewModel.shared.user.id)]
        ) { [weak self] (users: [User]) in
            guard let self = self else { return }
            
            if let user = users.first {
                let weightRecords = user.weightRecord
                let sortedWeightRecords = weightRecords.sorted { $0.createdTime.dateValue() < $1.createdTime.dateValue() }
                self.weightRecords = sortedWeightRecords
            }
        }
    }
    
    func addWeightRecord(_ record: WeightRecord) {
        weightRecords.append(record)
        weightRecords.sort { $0.createdTime.dateValue() < $1.createdTime.dateValue() }
        
        let userID = UserProfileViewModel.shared.user.id
        let docRef = FirestoreEndpoint.users.ref.document(userID)
        FirebaseManager.shared.setData(
            ["weightRecord": self.weightRecords],
            at: docRef,
            merge: true
        )
    }
}
