//
//  CoreDataManager.swift
//  CalorieMeter
//
//  Created by Pavel Klopat on 18.11.25.
//

import SwiftUI
import CoreData

// MARK: - Constants
private enum Constants {
    static var dataSavedSuccessfullyText: String { "Success! Data saved" }
    static var dataNotSavedText: String { "We could not save the data..." }
}

// MARK: - CoreDataManager
struct CoreDataManager {
    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "CalorieMeter")

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print("Failed to load the data \(error.localizedDescription), \(error.userInfo)")
                fatalError("Unresolved error")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func save(context: NSManagedObjectContext) {
        do {
            try context.save()
            print(Constants.dataSavedSuccessfullyText)
        } catch {
            print(Constants.dataNotSavedText)
        }
    }
    
    // Add new product to list
    func addEntity(titled title: String, caloriсСontent: Double, context: NSManagedObjectContext) {
        let product = ProductItem(context: context)
        product.id = UUID()
        product.fillingDate = Date()
        product.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        product.calories = caloriсСontent
        
        save(context: context)
    }
    
    // Update info of existing product
    func editEntity(_ product: ProductItem, with info: (String, calories: Double), context: NSManagedObjectContext) {
        product.title = info.0
        product.calories = info.calories
        
        save(context: context)
    }
    
    // Delete product from list
    func deleteEntities(offsets: IndexSet, products: FetchedResults<ProductItem>, context: NSManagedObjectContext) {
        offsets.map { products[$0] }.forEach(context.delete)
        CoreDataManager().save(context: context)
    }
    
    func checkForDuplicatesBy(predicate: String, product: (String, Double), showAlert: inout Bool, managedContext: NSManagedObjectContext, completion: () -> ()) {
        let fetchRequest: NSFetchRequest<ProductItem> = ProductItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "\(predicate) ==[c] %@", product.0)
        fetchRequest.fetchLimit = 1
        
        do {
            let count = try managedContext.count(for: fetchRequest)
            
            guard count == 0 else {
                showAlert = true
                return
            }
            
            withAnimation {
                CoreDataManager().addEntity(
                    titled: product.0,
                    caloriсСontent: product.1,
                    context: managedContext
                )
                
                completion()
            }
        } catch {
            print("Error checking duplicates: \(error.localizedDescription)")
            return
        }
    }
}
