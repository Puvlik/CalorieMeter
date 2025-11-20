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
    
    static var galleryPermissionAlertPrimaryText: String { "Gallery permission required" }
    static var galleryPermissionAlertSecondaryText: String { "Please allow access to your Photos in Settings to select an image" }
    static var openSettingsText: String { "Open Settings" }
    
    // Common button texts for all types of Alerts
    static var alertSaveButtonText: String { "Add" }
    static var alertCancelButtonText: String { "Cancel" }
    static var alertOKButtonText: String { "OK" }
    
    static var noCaloriesValue: CGFloat { 0 }
    
    static var photoPickerButtonText: String { "Add image" }
    static var photoPickerButtonHeight: CGFloat { 45 }
    static var photoPickerButtonTextFontSize: CGFloat { 18 }
    static var photoPickerButtonContentSpacing: CGFloat { 16 }
    
    static var addImageIconHeight: CGFloat { 24 }
    static var addImageIconWidth: CGFloat { 30 }
    
    static var fractionMinimumValue: CGFloat { 0.31 }
    static var fractionMaximumValue: CGFloat { 0.57 }
}

// MARK: - ProductUpdateSheetView
struct ProductUpdateSheetView: View {
    @StateObject private var permissionManager = PhotoPermissionManager()
    @Environment(\.managedObjectContext) var managedContext
    @Environment(\.dismiss) var dismiss
    
    @FocusState private var titleFieldIsFocused: Bool
    
    @State private var title = ""
    @State private var calories: Double? = nil
    @State private var pickedImage: UIImage?
    
    @State private var showImagePicker = false
    @State private var showDuplicateAlert = false
    @State private var errorAlertView: ProductErrorAlertConstructor?
    
    @State private var numberFormatter: NumberFormatter = {
        var numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .none
        return numberFormatter
    }()
    
    @Binding var selectedProduct: FetchedResults<ProductItem>.Element?
    
    var body: some View {
        Form {
            Section {
                TextField(Constants.productTitlePlaceholder, text: $title)
                    .focused($titleFieldIsFocused)
                
                TextField(Constants.productCaloriesPlaceholder, value: $calories, formatter: numberFormatter)
                    .keyboardType(.numberPad)
                
                if let uiImage = pickedImage ?? (selectedProduct?.image.flatMap { UIImage(data: $0) }) {
                    ProductLargeImageView(
                        permissionManager: permissionManager,
                        showImagePicker: $showImagePicker,
                        galleryPermissionAlert: $errorAlertView,
                        productImage: uiImage
                    )
                } else {
                    Button {
                        permissionManager.checkPermission()
                        
                        switch permissionManager.authorizationStatus {
                        case .authorized, .limited:
                            showImagePicker = true
                        case .denied, .restricted:
                            errorAlertView = ProductErrorAlertConstructor(
                                title: Constants.galleryPermissionAlertPrimaryText,
                                message: Constants.galleryPermissionAlertSecondaryText,
                                primaryButton: .default(Text(Constants.openSettingsText)) {
                                    if let url = URL(string: UIApplication.openSettingsURLString) {
                                        UIApplication.shared.open(url)
                                    }
                                },
                                secondaryButton: .cancel(Text(Constants.alertCancelButtonText)) {}
                            )
                        default:
                            break
                        }
                        // TODO: Сделать алерт типо у вас пермишшен закрыт фулл, измените настройки
                    } label: {
                        HStack(alignment: .center, spacing: Constants.photoPickerButtonContentSpacing) {
                            Spacer()
                            
                            Text(Constants.photoPickerButtonText)
                                .font(
                                    .system(size: Constants.photoPickerButtonTextFontSize, weight: .regular)
                                )
                            
                            Image(systemName: "photo.badge.plus")
                                .resizable()
                                .frame(width: Constants.addImageIconWidth, height: Constants.addImageIconHeight)
                            
                            Spacer()
                        }
                    }
                    .frame(height: Constants.photoPickerButtonHeight)
                }
            }
            
            HStack {
                Spacer()
                
                Button(Constants.saveButtonText) {
                    let validationResult = CoreDataManager().validateProductInformation(
                        productInfo: (title: title, calories: calories ?? Constants.noCaloriesValue),
                        exclude: selectedProduct,
                        managedContext: managedContext
                    )
                    
                    constructCustomAlert(accordingTo: validationResult)
                }
                
                Spacer()
            }
        }
        .scrollIndicators(.hidden)
        .listSectionSpacing(.compact)
        .presentationDetents([.fraction(
            // In rush for adaptive sheetView height when product image picked or not
            pickedImage == nil ? Constants.fractionMinimumValue : Constants.fractionMaximumValue)]
        )
        .onAppear {
            titleFieldIsFocused = true
            
            guard let selectedProduct,
                  let productTitle = selectedProduct.title else { return }
            
            title = productTitle
            calories = selectedProduct.calories
            pickedImage = selectedProduct.image.flatMap { UIImage(data: $0) }
        }
        .onChange(of: permissionManager.authorizationStatus) { oldStatus, newStatus in
            if newStatus == .authorized || newStatus == .limited {
                showImagePicker = true
            }
        }
        .alert(item: $errorAlertView) { alert in
            return alert.makeAlert()
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(selectedImage: $pickedImage)
        }
        .onDisappear {
            selectedProduct = nil
        }
    }
}

// MARK: - Extension
private extension ProductUpdateSheetView {
    // Save edited product
    private func editExistingProduct(_ product: ProductItem) {
        withAnimation(.spring) {
            CoreDataManager().editEntity(
                product,
                with: (title, calories: calories ?? Constants.noCaloriesValue),
                productImage: pickedImage,
                context: managedContext
            )
            
            dismiss()
        }
    }
    
    // Add new product to List
    private func saveNewProduct() {
        withAnimation(.spring) {
            CoreDataManager().addEntity(
                titled: title,
                calories: calories ?? Constants.noCaloriesValue,
                productImage: pickedImage,
                context: managedContext
            )
            
            dismiss()
        }
    }
    
    func constructCustomAlert(accordingTo vadidationResult: ProductFieldsCheckResult) {
        switch vadidationResult {
        case .success: // No alert, just save product to DB
            errorAlertView = nil
            
            if let product = selectedProduct {
                editExistingProduct(product)
            } else {
                saveNewProduct()
            }
            
        case .duplicate:
            errorAlertView = ProductErrorAlertConstructor(
                title: Constants.duplicatesAlertPrimaryText,
                message: Constants.duplicatesAlertSecondaryText,
                primaryButton: .default(Text(Constants.saveButtonText)) {
                    // If we editing existing product and it appears as duplicate,
                    // we need to edit existing entity, not creating new one
                    if let product = selectedProduct {
                        editExistingProduct(product)
                    } else {
                        saveNewProduct()
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
            
            errorAlertView = ProductErrorAlertConstructor(
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
