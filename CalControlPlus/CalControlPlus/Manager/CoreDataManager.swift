//
//  CoreDataManager.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/10/5.
//

import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "FoodItem")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }
    
    func saveFood(name: String, portion: String) {
        let context = persistentContainer.viewContext
        let foodItem = FoodItem(context: context)
        foodItem.name = name
        foodItem.portion = portion
        
        do {
            try context.save()
        } catch {
            print("Failed to save food item: \(error)")
        }
    }
    
    func fetchAllFoods() -> [FoodItem] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<FoodItem> = FoodItem.fetchRequest()
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch food items: \(error)")
            return []
        }
    }
    
    func deleteFood(_ foodItem: FoodItem) {
        let context = persistentContainer.viewContext
        context.delete(foodItem)
        
        do {
            try context.save()
        } catch {
            print("Failed to delete food item: \(error)")
        }
    }
}
