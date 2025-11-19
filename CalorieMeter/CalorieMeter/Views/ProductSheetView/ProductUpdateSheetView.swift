//
//  ProductUpdateSheetView.swift
//  CalorieMeter
//
//  Created by Pavel Klopat on 18.11.25.
//

import SwiftUI
import CoreData

// MARK: - Constants
private enum Constants {
    static var productTitlePlaceholder: String { "Product title..." }
    static var productCaloriesPlaceholder: String { "Product calories..." }
    static var saveButtonText: String { "Save" }
    
    static var duplicatesAlertMainText: String { "Product already exists!\nAdd anyway?" }
    static var duplicatesAlertSecondaryText: String { "You can edit existing product and update calories value" }
    static var alertSaveButtonText: String { "Add" }
    static var alertCancelButtonText: String { "Cancel" }
    
    static var noCaloriesValue: CGFloat { 0 }
}

// MARK: - ProductUpdateSheetView
struct ProductUpdateSheetView: View {
    @Environment(\.managedObjectContext) var managedContext
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var calories: Double? = nil
    
    @State private var numberFormatter: NumberFormatter = {
        var numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .none
        return numberFormatter
    }()
    
    @Binding var selectedProduct: FetchedResults<ProductItem>.Element?
    
    @State private var showDuplicateAlert = false
    
    var body: some View {
        Form {
            Section {
                TextField(Constants.productTitlePlaceholder, text: $title)
                
                TextField(Constants.productCaloriesPlaceholder, value: $calories, formatter: numberFormatter)
                    .keyboardType(.numberPad)
            }
            
            HStack {
                Spacer()
                
                Button(Constants.saveButtonText) {
                    guard let product = selectedProduct else {
                        CoreDataManager().checkForDuplicatesBy(
                            predicate: "title",
                            product: (title, calories ?? Constants.noCaloriesValue),
                            showAlert: &showDuplicateAlert,
                            managedContext: managedContext
                        ) {
                            dismiss()
                        }

                        return
                    }
                    
                    withAnimation {
                        CoreDataManager().editEntity(
                            product,
                            with: (title, calories: calories ?? Constants.noCaloriesValue),
                            context: managedContext
                        )
                        
                        selectedProduct = nil
                        dismiss()
                    }
                }
                
                Spacer()
            }
        }
        .onAppear {
            guard let selectedProduct,
                    let productTitle = selectedProduct.title else { return }
            
            title = productTitle
            calories = selectedProduct.calories
        }
        .listSectionSpacing(.compact)
        .alert(Constants.duplicatesAlertMainText, isPresented: $showDuplicateAlert) {
            Button(Constants.saveButtonText) {
                withAnimation {
                    CoreDataManager().addEntity(
                        titled: title,
                        caloriсСontent: calories ?? Constants.noCaloriesValue,
                        context: managedContext
                    )
                    
                    dismiss()
                }
            }
            
            Button(Constants.alertCancelButtonText, role: .cancel) {
                dismiss()
            }
        } message: {
            Text(Constants.duplicatesAlertSecondaryText)
        }
    }
}
