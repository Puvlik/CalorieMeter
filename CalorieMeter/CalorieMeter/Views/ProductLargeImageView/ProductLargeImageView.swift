//
//  ProductLargeImageView.swift
//  CalorieMeter
//
//  Created by Pavel Klopat on 19.11.25.
//

import SwiftUI

// MARK: - Constants
private enum Constants {
    static var productImageHeight: CGFloat { 200 }
    static var productImageCornerRadius: CGFloat { 24 }
    
    static var newImageIconWidth: CGFloat { 25 }
    static var newImageIconHeight: CGFloat { 20 }
    static var newImageIconTopLeadingPadding: CGFloat { 2 }
    
    static var buttonWidth: CGFloat { 42 }
    static var buttonHeight: CGFloat { 38 }
    static var buttonCornerRadius: CGFloat { 12 }
    static var buttonBorderWidth: CGFloat { 2 }
    static var buttonTopTrailingPadding: CGFloat { 10 }
    
    static var galleryPermissionAlertPrimaryText: String { "Gallery permission required" }
    static var galleryPermissionAlertSecondaryText: String { "Please allow access to your Photos in Settings to select an image" }
    static var openSettingsText: String { "Open Settings" }
    static var alertCancelButtonText: String { "Cancel" }
}

// MARK: - ProductLargeImageView
struct ProductLargeImageView: View {
    @ObservedObject var permissionManager: PhotoPermissionManager
    
    @Binding var showImagePicker: Bool
    @Binding var galleryPermissionAlert: ProductErrorAlertConstructor?
    
    var productImage: UIImage
    
    var body: some View {
        ViewThatFits {
            ZStack(alignment: .topTrailing) {
                Image(uiImage: productImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: Constants.productImageCornerRadius))
                
                Button {
                    permissionManager.checkPermission()
                    
                    switch permissionManager.authorizationStatus {
                    case .authorized, .limited:
                        showImagePicker = true
                    case .denied, .restricted:
                        galleryPermissionAlert = ProductErrorAlertConstructor(
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
                } label: {
                    Image(systemName: "photo.badge.magnifyingglass")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: Constants.newImageIconWidth, height: Constants.newImageIconHeight)
                        .foregroundStyle(.black)
                        .padding([.leading, .top], Constants.newImageIconTopLeadingPadding)
                }
                .frame(width: Constants.buttonWidth, height: Constants.buttonHeight)
                .buttonStyle(.plain)
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.buttonCornerRadius)
                        .stroke(
                            Color("customButtonBorderColor"),
                            lineWidth: Constants.buttonBorderWidth
                        )
                )
                .background(
                    RoundedRectangle(cornerRadius: Constants.buttonCornerRadius)
                        .foregroundColor(Color("customButtonBackgroundColor"))
                )
                .padding([.trailing, .top], Constants.buttonTopTrailingPadding)
            }
        }
    }
}
