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
    
    static var fetchRequestLimit: Int { 1 }
    static var imageCompressionQuality: CGFloat { 0.8 }
}

// MARK: Enums
// ProductCheckResult used for fields validation controlling state of adding new products
enum ProductFieldsCheckResult {
    // EmptyFieldsDataIssue for validating what fields is causing an issue
    enum EmptyFieldsDataIssue {
        // EmptyField for validating what field is not filled while second one is OK
        enum EmptyField {
            case productTitle
            case productCalories
        }
        
        case bothFieldsEmpty
        // Title field or calories field is empty
        case fieldEmpty(EmptyField)
    }
    
    // No errors or duplicates
    case success
    // At least one duplicate is found
    case duplicate
    // One or any fields are not filled
    case emptyData(EmptyFieldsDataIssue)
    case failure(Error)
}

// MARK: - CoreDataManager
final class CoreDataManager {
    let container: NSPersistentContainer

    // MARK: - Init
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
    func addEntity(
        titled title: String,
        calories: Double,
        productImage: UIImage?,
        context: NSManagedObjectContext
    ) {
        let product = ProductItem(context: context)
        product.id = UUID()
        product.fillingDate = Date()
        product.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        product.calories = calories
        
        if let image = productImage {
            product.image = image.jpegData(compressionQuality: Constants.imageCompressionQuality)
        }
        
        save(context: context)
    }
    
    // Update info of existing product
    func editEntity(
        _ product: ProductItem,
        with info: (String, calories: Double),
        productImage: UIImage?,
        context: NSManagedObjectContext
    ) {
        product.title = info.0
        product.calories = info.calories
        
        if let image = productImage {
            product.image = image.jpegData(compressionQuality: Constants.imageCompressionQuality)
        }
        
        save(context: context)
    }
    
    // Delete product from list
    func deleteEntity(offsets: IndexSet, products: FetchedResults<ProductItem>, context: NSManagedObjectContext) {
        offsets.map { products[$0] }.forEach(context.delete)
        CoreDataManager().save(context: context)
    }
    
    // Validate all fields to find empty values or duplicates
    func validateProductInformation(
        productInfo: (title: String, calories: Double),
        exclude productToExclude: ProductItem? = nil,
        managedContext: NSManagedObjectContext
    ) -> ProductFieldsCheckResult {
        let titleIsEmpty = productInfo.title.isEmpty
        let caloriesIsZero = productInfo.calories == 0

        switch (titleIsEmpty, caloriesIsZero) {
        case (true, true): return .emptyData(.bothFieldsEmpty)
        case (true, _): return .emptyData(.fieldEmpty(.productTitle))
        case (_, true): return .emptyData(.fieldEmpty(.productCalories))
        default: break
        }

        let fetchRequest: NSFetchRequest<ProductItem> = ProductItem.fetchRequest()
        fetchRequest.fetchLimit = Constants.fetchRequestLimit
        
        if let id = productToExclude?.id {
            // To exclude selected product from searching for duplicates
            fetchRequest.predicate = NSPredicate(format: "title ==[c] %@ AND id != %@", productInfo.title, id as CVarArg)
        } else {
            fetchRequest.predicate = NSPredicate(format: "title ==[c] %@", productInfo.title)
        }
        
        do {
            let matches = try managedContext.count(for: fetchRequest)
            return (matches > 0 ? .duplicate : .success)
        } catch {
            print("Error checking duplicates: \(error.localizedDescription)")
            return .failure(error)
        }
    }
}
