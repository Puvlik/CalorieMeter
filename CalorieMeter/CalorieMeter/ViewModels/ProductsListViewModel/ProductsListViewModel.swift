//
//  ProductsListViewModel.swift
//  CalorieMeter
//
//  Created by Pavel Klopat on 20.11.25.
//

import SwiftUI
import CoreData

// MARK: - ProductsListViewModel
class ProductsListViewModel: ObservableObject {
    @Published var showEditProductSheet = false
    @Published var showDeleteAlert = false
    
    @Published var productToEdit: ProductItem?
    @Published var productToDelete: ProductItem?
    
    // MARK: - Core Data
    private let context: NSManagedObjectContext
    
    // MARK: - Init
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - User Actions
    func setStateForProductEditing(_ product: ProductItem) {
        productToEdit = product
        showEditProductSheet = true
    }
    
    func setStateForProductDeletion(_ product: ProductItem) {
        productToDelete = product
        showDeleteAlert = true
    }
    
    func approveProductForDeletion(from products: FetchedResults<ProductItem>) {
        guard let item = productToDelete,
              let index = products.firstIndex(of: item) else { return }
        
        withAnimation(.spring) {
            CoreDataManager().deleteEntity(
                offsets: IndexSet(integer: index),
                products: products,
                context: context
            )
            
            clearDeletionState()
        }
    }
    
    func clearDeletionState() {
        productToDelete = nil
        showDeleteAlert = false
    }
    
    // MARK: - Total calories calculations in products list
    func totalCaloriesSummary(for products: FetchedResults<ProductItem>) -> Int {
        products.map { Int($0.calories) }.reduce(0, +)
    }
}
