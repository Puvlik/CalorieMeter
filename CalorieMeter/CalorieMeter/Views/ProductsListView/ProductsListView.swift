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
    @StateObject private var viewModel: ProductsListViewModel
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.fillingDate, order: .reverse)])
    private var fetchedProducts: FetchedResults<ProductItem>
    
    // MARK: - Init
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: ProductsListViewModel(context: context))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.mainViewContentSpacing) {
            VStack(alignment: .center) {
                HStack(alignment: .center) {
                    Text(Constants.totalCaloriesText + "\(viewModel.totalCaloriesSummary(for: fetchedProducts))")
                        .font(.title)
                        .bold()
                    
                    Spacer()
                    
                    AddNewProductButton(openSheetView: $viewModel.showEditProductSheet)
                }
                
                Divider()
                    .frame(height: Constants.dividerHeight)
                    .padding(.top, Constants.dividerTopPadding)
            }
            .padding(.horizontal)
            .padding(.top, Constants.totalCaloriesTopPadding)
            
            List {
                ForEach(fetchedProducts) { product in
                    setupProductListRow(with: product)
                }
            }
            .listStyle(.plain)
        }
        .sheet(isPresented: $viewModel.showEditProductSheet) {
            ProductUpdateSheetView(selectedProduct: $viewModel.productToEdit)
        }
        // For some reason CustomAlertView is not showing List reload animation, so here we use default one
        .alert(Constants.deletionAlertPrimaryText, isPresented: $viewModel.showDeleteAlert) {
            Button(Constants.alertDeleteButtonText, role: .destructive) {
                viewModel.approveProductForDeletion(from: fetchedProducts)
            }
            
            Button(Constants.alertCancelButtonText, role: .cancel) {
                viewModel.clearDeletionState()
            }
        } message: {
            Text(Constants.deletionAlertSecondaryText)
        }
    }
}

extension ProductsListView {
    private func setupProductListRow(with product: ProductItem) -> some View {
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
                viewModel.setStateForProductEditing(product)
            } label: {
                Label(Constants.editSwipeButtonLabelText, systemImage: "pencil")
            }
            .tint(.indigo)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                viewModel.setStateForProductDeletion(product)
            } label: {
                Label(Constants.deleteSwipeButtonLabelText, systemImage: "trash")
            }
            .tint(.red)
        }
    }
}
