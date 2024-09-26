//
//  HomeViewModel.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/19.
//

import Combine
import FirebaseFirestore

class HomeViewModel: ObservableObject {
    @Published var foodRecords: [FoodRecord] = []
    @Published var exerciseValue: Int = 0
    @Published var totalNutrition: TotalNutrition?
    
    let mealCategories = ["早餐", "午餐", "晚餐", "點心"]
    
    private var cancellables = Set<AnyCancellable>()
    
    var foodRecordsByCategory: [[FoodRecord]] {
        var categorizedRecords: [[FoodRecord]] = [[], [], [], []]
        
        for record in foodRecords {
            categorizedRecords[record.mealType].append(record)
        }
        return categorizedRecords
    }
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        $foodRecords
            .sink { [weak self] newRecords in
                guard let self = self else { return }
                self.recalculateTotalNutrition(from: newRecords)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func fetchFoodRecord(for date: Date) {
        let conditions = generateQueryConditions(for: date)
        
        FirebaseManager.shared.getDocuments(
            from: .foodRecord,
            where: conditions
        ) { [weak self] (records: [FoodRecord]) in
            guard let self = self else { return }
            self.foodRecords = records
            self.totalNutrition = NutritionCalculator.calculateTotalNutrition(from: records, for: Calendar.current.startOfDay(for: date))
        }
    }
    
    func addObserver(for date: Date) {
        let conditions = generateQueryConditions(for: date)
        
        FirebaseManager.shared.addObserver(
            on: .foodRecord,
            where: conditions
        ) { [weak self] (changeType: DocumentChangeType, foodRecord: FoodRecord) in
            guard let self = self else { return }
            switch changeType {
            case .added:
                self.foodRecords.append(foodRecord)
                
            case .modified:
                if let index = self.foodRecords.firstIndex(where: { $0.id == foodRecord.id }) {
                    self.foodRecords[index] = foodRecord
                }
                
            case .removed:
                if let index = self.foodRecords.firstIndex(where: { $0.id == foodRecord.id }) {
                    self.foodRecords.remove(at: index)
                }
            }
        }
    }
    
    private func generateQueryConditions(for date: Date) -> [FirestoreCondition] {
        let dateOnly = Calendar.current.startOfDay(for: date)
        let timestamp = Timestamp(date: dateOnly)
        
        return [
            FirestoreCondition(field: "userID", comparison: .isEqualTo, value: UserProfileViewModel.shared.user.id),
            FirestoreCondition(field: "date", comparison: .isEqualTo, value: timestamp)
        ]
    }
    
    private func recalculateTotalNutrition(from records: [FoodRecord]) {
        let dateOnly = Calendar.current.startOfDay(for: Date())
        self.totalNutrition = NutritionCalculator.calculateTotalNutrition(from: records, for: dateOnly)
    }
}
