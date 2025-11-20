//
//  AddNewProductButton.swift
//  CalorieMeter
//
//  Created by Pavel Klopat on 18.11.25.
//

import SwiftUI

// MARK: - Constants
private enum Constants {
    static var buttonTextString: String { "Add" }
    static var buttonTextSize: CGFloat { 18 }
    static var buttonContentSpacing: CGFloat { 8 }
    static var buttonWidth: CGFloat { 90 }
    static var buttonHeight: CGFloat { 40 }
    static var buttonCornerRadius: CGFloat { 16 }
    static var buttonBorderWidth: CGFloat { 2 }
    
    static var cartIconWidth: CGFloat { 25 }
    static var cartIconHeight: CGFloat { 20 }
    static var cartIconBottomPadding: CGFloat { 4 }
}

// MARK: - AddNewProductButton
struct AddNewProductButton: View {
    @Binding var openSheetView: Bool
    
    var body: some View {
        Button {
            openSheetView.toggle()
        } label: {
            HStack(alignment: .center, spacing: Constants.buttonContentSpacing) {
                Text(Constants.buttonTextString)
                    .font(.system(size: Constants.buttonTextSize, weight: .semibold))
                
                Image(systemName: "cart.badge.plus")
                    .resizable()
                    .frame(width: Constants.cartIconWidth, height: Constants.cartIconHeight)
                    .padding(.bottom, Constants.cartIconBottomPadding)
            }
        }
        .foregroundColor(.black)
        .frame(width: Constants.buttonWidth, height: Constants.buttonHeight)
        .background(
            RoundedRectangle(cornerRadius: Constants.buttonCornerRadius)
                .foregroundColor(Color("customButtonBackgroundColor"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: Constants.buttonCornerRadius)
                .stroke(
                    Color("customButtonBorderColor"),
                    lineWidth: Constants.buttonBorderWidth
                )
        )
    }
}
