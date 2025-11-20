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
}

// MARK: - ProductLargeImageView
struct ProductLargeImageView: View {
    @Binding var showImagePicker: Bool
    
    var productImage: UIImage
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: productImage)
                .resizable()
                .scaledToFill()
                .frame(height: Constants.productImageHeight)
                .clipShape(RoundedRectangle(cornerRadius: Constants.productImageCornerRadius))
            
            Button {
                showImagePicker = true
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
