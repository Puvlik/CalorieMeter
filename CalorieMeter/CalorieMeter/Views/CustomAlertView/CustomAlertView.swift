//
//  CustomAlertView.swift
//  CalorieMeter
//
//  Created by Pavel Klopat on 19.11.25.
//

import SwiftUI

struct CustomAlertView: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let primaryButton: Alert.Button
    let secondaryButton: Alert.Button?

    func makeAlert() -> Alert {
        if let secondary = secondaryButton {
            return Alert(
                title: Text(title),
                message: Text(message),
                primaryButton: primaryButton,
                secondaryButton: secondary
            )
        } else {
            return Alert(
                title: Text(title),
                message: Text(message),
                dismissButton: primaryButton
            )
        }
    }
}
