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
    // SheetView palceholders and button text
    static var productTitlePlaceholder: String { "Product title..." }
    static var productCaloriesPlaceholder: String { "Product calories..." }
    static var saveButtonText: String { "Save" }
    
    // Alert primary and secondary texts if duplicates are found
    static var duplicatesAlertPrimaryText: String { "Product already exists!\nAdd anyway?" }
    static var duplicatesAlertSecondaryText: String { "You can edit existing product and update calories value" }
    
    // Alert primary and secondary texts if both text fields are empty
    static var noFieldsFilledAlertPrimaryText: String { "Product title can't be empty and calories value can't be empty or zero" }
    static var noFieldsFilledAlertSecondaryText: String { "Please fill in both fields and try again" }
    
    // Alert primary and secondary texts if product title field is empty
    static var productTitleNotFilledPrimaryText: String { "Product title can't be empty" }
    static var productTitleNotFilledSecondaryText: String { "Please fill in product title field" }
    
    // Alert primary and secondary texts if product calories field is empty
    static var productCaloriesNotFilledPrimaryText: String { "Product calories can't be empty or zero" }
    static var productCaloriesNotFilledSecondaryText: String { "Please update or fill in product calories field" }
    
    // Common button texts for all types of Alerts
    static var alertSaveButtonText: String { "Add" }
    static var alertCancelButtonText: String { "Cancel" }
    static var alertOKButtonText: String { "OK" }
    
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
    @State private var customAlertView: CustomAlertView?
    
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
                        let vadidationResult = CoreDataManager().validateProductInformation(
                            productInfo: (title: title, calories: calories ?? Constants.noCaloriesValue),
                            managedContext: managedContext
                        )
                        
                        constructCustomAlert(accordingTo: vadidationResult)

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
        .alert(item: $customAlertView) { alert in
            alert.makeAlert()
        }
    }
}

// MARK: - Extension
private extension ProductUpdateSheetView {
    func constructCustomAlert(accordingTo vadidationResult: ProductCheckResult) {
        switch vadidationResult {
        case .success: // No alert, just save product to DB
            customAlertView = nil
            
            withAnimation {
                CoreDataManager().addEntity(
                    titled: title,
                    caloriсСontent: calories ?? Constants.noCaloriesValue,
                    context: managedContext
                )
                
                dismiss()
            }
            
        case .duplicate:
            customAlertView = CustomAlertView(
                title: Constants.duplicatesAlertPrimaryText,
                message: Constants.duplicatesAlertSecondaryText,
                primaryButton: .default(Text(Constants.saveButtonText)) {
                    withAnimation {
                        CoreDataManager().addEntity(
                            titled: title,
                            caloriсСontent: calories ?? Constants.noCaloriesValue,
                            context: managedContext
                        )
                        
                        dismiss()
                    }
                },
                secondaryButton: .cancel(Text(Constants.alertCancelButtonText)) {
                    dismiss()
                }
            )
            
        case .emptyData(let issue):
            var issuePrimaryText: String
            var issueSecondaryText: String
            
            switch issue {
            case .bothFieldsEmpty:
                issuePrimaryText = Constants.noFieldsFilledAlertPrimaryText
                issueSecondaryText = Constants.noFieldsFilledAlertSecondaryText
            case .fieldEmpty(let emptyField):
                switch emptyField {
                case .productTitle:
                    issuePrimaryText = Constants.productTitleNotFilledPrimaryText
                    issueSecondaryText = Constants.productTitleNotFilledSecondaryText
                case .productCalories:
                    issuePrimaryText = Constants.productCaloriesNotFilledPrimaryText
                    issueSecondaryText = Constants.productCaloriesNotFilledSecondaryText
                }
            }
            
            customAlertView = CustomAlertView(
                title: issuePrimaryText,
                message: issueSecondaryText,
                primaryButton: .cancel(Text(Constants.alertOKButtonText)) {},
                secondaryButton: nil
            )

        case .failure(_):
            return
        }
    }
}
