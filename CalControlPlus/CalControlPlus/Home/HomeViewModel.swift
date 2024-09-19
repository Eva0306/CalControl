//
//  HomeViewModel.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/19.
//

import Combine
import FirebaseFirestore

class HomeViewModel: ObservableObject {
    @Published var foodRecord: [FoodRecord] = []
    
    func fetchFoodRecord(for date: Date) {
        let dateOnly = Calendar.current.startOfDay(for: date)
        let timestamp = Timestamp(date: dateOnly)
        
        FirebaseManager.shared.getDocuments(from: .foodRecord, where: "date", isEqualTo: timestamp) { [weak self] (records: [FoodRecord]) in
            guard let self = self else { return }
            self.foodRecord = records
        }
    }
}
