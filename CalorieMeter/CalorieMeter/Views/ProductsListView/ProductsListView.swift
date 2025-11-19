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
    static var emptyString: String { "" }
    static var totalCaloriesText: String { "Total kcal: " }
    static var editSwipeButtonLabelText: String { "Edit" }
    static var deleteSwipeButtonLabelText: String { "Delete" }
    
    static var mainViewContentSpacing: CGFloat { 0 }
    static var productRowHorizontalSpacing: CGFloat { 8 }
    static var productRowImageWidth: CGFloat { 85 }
    static var productRowImageHeight: CGFloat { 50 }
    static var productRowImageCornerRadius: CGFloat { 12 }
    
    static var totalCaloriesTopPadding: CGFloat { 16 }
    static var dividerHeight: CGFloat { 1 }
    static var dividerTopPadding: CGFloat { 8 }
    
    static var deletionAlertPrimaryText: String { "Are you sure you want to remove this product?" }
    static var deletionAlertSecondaryText: String { "This action cannot be undone" }
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
    
    private var allProductsCaloriesTotalSummary: Int {
        products.map { Int($0.calories) }.reduce(0, +)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.mainViewContentSpacing) {
            VStack(alignment: .center) {
                HStack(alignment: .center) {
                    Text(Constants.totalCaloriesText + "\(allProductsCaloriesTotalSummary)")
                        .font(.title)
                        .bold()
                    
                    Spacer()
                    
                    AddNewProductButton(openSheetView: $showAddProductSheetView)
                }
                
                Divider()
                    .frame(height: Constants.dividerHeight)
                    .padding(.top, Constants.dividerTopPadding)
            }
            .padding(.horizontal)
            .padding(.top, Constants.totalCaloriesTopPadding)
            
            List {
                ForEach(products) { product in
                    HStack(alignment: .center, spacing: Constants.productRowHorizontalSpacing) {
                        // Its impossible to get title == nil, but anyway lets avoid force unwrap
                        Text(product.title ?? Constants.emptyString)
                            .bold()
                        
                        Spacer()

                        if let data = product.image, let image = UIImage(data: data) {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: Constants.productRowImageWidth, height: Constants.productRowImageHeight)
                                .clipShape(RoundedRectangle(cornerRadius: Constants.productRowImageCornerRadius))
                        }
                        
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
                        Button {
                            productToDelete = product
                            showDeleteAlert.toggle()
                        } label: {
                            Label(Constants.deleteSwipeButtonLabelText, systemImage: "trash")
                        }
                        .tint(.red)
                    }
                }
            }
            .listStyle(.plain)
        }
        .sheet(isPresented: $showAddProductSheetView) {
            ProductUpdateSheetView(selectedProduct: $productToEdit)
        }
        // For some reason CustomAlertView is not showing List reload animation, so here we use default one
        .alert(Constants.deletionAlertPrimaryText, isPresented: $showDeleteAlert) {
            Button(Constants.alertDeleteButtonText, role: .destructive) {
                if let item = productToDelete,
                   let index = products.firstIndex(of: item) {
                    withAnimation(.spring) {
                        CoreDataManager().deleteEntity(
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
            Text(Constants.deletionAlertSecondaryText)
        }
    }
}
