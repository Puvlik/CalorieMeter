//
//  ProductsListView.swift
//  CalorieMeter
//
//  Created by Pavel Klopat on 18.11.25.
//

import SwiftUI
import CoreData

// MARK: - Constants
private enum Constants {
    static var totalCaloriesText: String { "Total kcal: " }
    static var editSwipeButtonLabelText: String { "Edit" }
    static var deleteSwipeButtonLabelText: String { "Delete" }
    
    static var totalCaloriesTopPadding: CGFloat { 16 }
    static var dividerHeight: CGFloat { 1 }
    static var newProductSheetHeight: CGFloat { 200 }
    
    static var alertMainText: String { "Are you sure you want to remove this product?" }
    static var alertSecondaryText: String { "This action cannot be undone" }
    static var alertDeleteButtonText: String { "Delete" }
    static var alertCancelButtonText: String { "Cancel" }
}

// MARK: - ProductsListView
struct ProductsListView: View {
    @Environment(\.managedObjectContext) private var managedContext
    
    @State private var showAddProductSheetView = false
    @State private var showDeleteAlert = false
    @State private var productToDelete: ProductItem?
    @State private var productToEdit: ProductItem?
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.fillingDate, order: .reverse)])

    private var products: FetchedResults<ProductItem>
    
    private var totalCalories: Int {
        products.map { Int($0.calories) }.reduce(0, +)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .center) {
                HStack(alignment: .center) {
                    Text(Constants.totalCaloriesText + "\(totalCalories)")
                        .font(.title)
                        .bold()
                    
                    Spacer()
                    
                    AddNewProductButton(openSheetView: $showAddProductSheetView)
                }
                
                Divider()
                    .frame(height: Constants.dividerHeight)
                    .overlay(Color("dividerColor"))
            }
            .padding(.horizontal)
            .padding(.top, Constants.totalCaloriesTopPadding)
            
            List {
                ForEach(products.filter { $0.title != nil }) { product in
                    HStack {
                        Text(product.title!)
                            .bold()
                        
                        Spacer()
                        
                        Text("\(Int(product.calories))")
                            .foregroundColor(.gray)
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        Button {
                            productToEdit = product
                            showAddProductSheetView.toggle()
                        } label: {
                            Label(Constants.editSwipeButtonLabelText, systemImage: "pencil")
                        }
                        .tint(.indigo)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            productToDelete = product
                            showDeleteAlert.toggle()
                        } label: {
                            Label(Constants.deleteSwipeButtonLabelText, systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
        .sheet(isPresented: $showAddProductSheetView) {
            ProductUpdateSheetView(selectedProduct: $productToEdit)
                .presentationDetents([.height(Constants.newProductSheetHeight)])
        }
        .alert(Constants.alertMainText, isPresented: $showDeleteAlert) {
            Button(Constants.alertDeleteButtonText, role: .destructive) {
                if let item = productToDelete,
                   let index = products.firstIndex(of: item) {
                    withAnimation {
                        CoreDataManager().deleteEntities(
                            offsets: IndexSet(integer: index),
                            products: products,
                            context: managedContext
                        )
                    }
                }
            }
            
            Button(Constants.alertCancelButtonText, role: .cancel) {
                productToDelete = nil
            }
        } message: {
            Text(Constants.alertSecondaryText)
        }
    }
}
