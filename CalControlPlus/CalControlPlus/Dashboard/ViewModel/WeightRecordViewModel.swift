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
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.weightRecords = UserProfileViewModel.shared.user.weightRecord
        
        UserProfileViewModel.shared.$user
            .map { $0.weightRecord }
            .sink { [weak self] weightRecords in
                self?.weightRecords = weightRecords
            }
            .store(in: &cancellables)
    }
    
    func addWeightRecord(_ record: WeightRecord) {
        weightRecords.append(record)
        weightRecords.sort { $0.createdTime.dateValue() < $1.createdTime.dateValue() }
        
        UserProfileViewModel.shared.user.weightRecord = weightRecords
        
        updateWeightRecordInFirebase()
    }
    
    func saveOrReplaceRecord(for date: Date, weight: Double) {
        if let index = weightRecords.firstIndex(
            where: { Calendar.current.isDate($0.createdTime.dateValue(), inSameDayAs: date) }
        ) {
            weightRecords[index].weight = weight
        } else {
            let newRecord = WeightRecord(createdTime: Timestamp(date: date), weight: weight)
            addWeightRecord(newRecord)
        }
        
        UserProfileViewModel.shared.user.weightRecord = weightRecords
        
        updateWeightRecordInFirebase()
    }
    
    private func updateWeightRecordInFirebase() {
        let userID = UserProfileViewModel.shared.user.id
        let docRef = FirestoreEndpoint.users.ref.document(userID)
        
        FirebaseManager.shared.setData(
            ["weightRecord": weightRecords],
            at: docRef,
            merge: true
        )
    }
    
    func checkIfRecordExists(for date: Date) -> RecordCheckResult? {
        if let index = weightRecords.firstIndex(where: { Calendar.current.isDate($0.createdTime.dateValue(), inSameDayAs: date) }) {
            return RecordCheckResult(index: index, weight: weightRecords[index].weight)
        }
        return nil
    }
}
