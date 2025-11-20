//
//  PhotoPermissionManager.swift
//  CalorieMeter
//
//  Created by Pavel Klopat on 20.11.25.
//

import SwiftUI
import PhotosUI

// MARK: - PhotoPermissionManager
final class PhotoPermissionManager: ObservableObject {
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    
    var isAuthorized: Bool {
        authorizationStatus == .authorized || authorizationStatus == .limited
    }

    func checkPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        authorizationStatus = status

        switch status {
        case .notDetermined:
            requestPermission()
        default:
            break
        }
    }

    func requestPermission() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                self.authorizationStatus = status
            }
        }
    }
}
