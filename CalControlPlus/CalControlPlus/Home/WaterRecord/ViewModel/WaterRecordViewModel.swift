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
    @Published var cupSize: Int = 250 // 每杯水的預設量
    
    var totalWaterAmount: Int {
        return currentWaterIntake * cupSize
    }

    private var waterRecord: WaterRecord?
    
    func updateWaterIntake(date: Date, for intake: Int) {
        
        currentWaterIntake = intake
        
        let dateOnly = Calendar.current.startOfDay(for: date)
        let timestamp = Timestamp(date: dateOnly)
        
        FirebaseManager.shared.getDocuments(from: .waterRecord, where: "date", isEqualTo: timestamp) { [weak self] (records: [WaterRecord]) in
            guard let self = self else { return }
            
            if let record = records.first {
                // 如果當天已有記錄，更新該記錄
                self.waterRecord = record
                self.currentWaterIntake = intake
                
                // 獲取該記錄的 documentID
                let docRef = FirebaseManager.shared.newDocument(of: .waterRecord, documentID: record.id)
                
                self.waterRecord?.totalWaterIntake = intake * self.cupSize
                
                // 更新數據
                FirebaseManager.shared.setData(self.waterRecord, at: docRef)
                
            } else {
                // 如果當天沒有記錄，創建新的記錄
                self.createNewWaterRecord(date: timestamp)
            }
        }
    }
    
    // Fetch water record by date (using startOfDay)
    func fetchWaterRecord(for date: Date) {
        let dateOnly = Calendar.current.startOfDay(for: date)
        let timestamp = Timestamp(date: dateOnly)
        
        FirebaseManager.shared.getDocuments(from: .waterRecord, where: "date", isEqualTo: timestamp) { [weak self] (records: [WaterRecord]) in
            guard let self = self else { return }
            
            if let record = records.first {
                // If a record is found for the current day
                self.waterRecord = record
                self.currentWaterIntake = record.totalWaterIntake / cupSize
            } else {
                // If no record is found, create a new record
                self.createNewWaterRecord(date: timestamp)
            }
        }
    }
    
    // Create a new water record for the current day
    private func createNewWaterRecord(date: Timestamp) {
        let docRef = FirebaseManager.shared.newDocument(of: FirestoreEndpoint.waterRecord)
        
        let newRecord = WaterRecord(
            id: docRef.documentID,
            userID: "Eva123",
            date: date,
            totalWaterIntake: currentWaterIntake * cupSize
        )
        
        FirebaseManager.shared.setData(newRecord, at: docRef)
        self.waterRecord = newRecord
    }
}
