//
//  WaterRecordViewModel.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/18.
//

import Combine
import FirebaseFirestore

class WaterRecordViewModel: ObservableObject {
    @Published var currentWaterIntake: Int = 0
    @Published var cupSize: Int = 250
    
    var totalWaterAmount: Int {
        return currentWaterIntake * cupSize
    }

    private var waterRecord: WaterRecord?
    
    func updateWaterIntake(date: Date, for intake: Int) {
        currentWaterIntake = intake
        
        let dateOnly = Calendar.current.startOfDay(for: date)
        let timestamp = Timestamp(date: dateOnly)
        
        let condition = [
            FirestoreCondition(field: "userID", comparison: .isEqualTo, value: UserProfileViewModel.shared.user.id),
            FirestoreCondition(field: "date", comparison: .isEqualTo, value: timestamp)
        ]
        
        FirebaseManager.shared.getDocuments(
            from: .waterRecord,
            where: condition
        ) { [weak self] (records: [WaterRecord]) in
            guard let self = self else { return }
            
            if let record = records.first {
                self.waterRecord = record
                
                let docRef = FirebaseManager.shared.newDocument(of: .waterRecord, documentID: record.id)
                self.waterRecord?.totalWaterIntake = intake * self.cupSize
                
                FirebaseManager.shared.setData(self.waterRecord, at: docRef)
                
            } else {
                self.createNewWaterRecord(date: timestamp)
            }
        }
    }

    func fetchWaterRecord(for date: Date) {
        let dateOnly = Calendar.current.startOfDay(for: date)
        let timestamp = Timestamp(date: dateOnly)
        
        let condition = [
        FirestoreCondition(field: "userID", comparison: .isEqualTo, value: UserProfileViewModel.shared.user.id),
        FirestoreCondition(field: "date", comparison: .isEqualTo, value: timestamp)
        ]
        
        FirebaseManager.shared.getDocuments(
            from: .waterRecord,
            where: condition
        ) { [weak self] (records: [WaterRecord]) in
            guard let self = self else { return }
            
            if let record = records.first {
                self.waterRecord = record
                self.currentWaterIntake = record.totalWaterIntake / cupSize
            } else {
                self.createNewWaterRecord(date: timestamp)
            }
        }
    }
    
    private func createNewWaterRecord(date: Timestamp) {
        let docRef = FirebaseManager.shared.newDocument(of: FirestoreEndpoint.waterRecord)
        
        let newRecord = WaterRecord(
            id: docRef.documentID,
            userID: UserProfileViewModel.shared.user.id,
            date: date,
            totalWaterIntake: 0
        )
        
        FirebaseManager.shared.setData(newRecord, at: docRef)
        self.waterRecord = newRecord
    }
}
