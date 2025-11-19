//
//  CalorieMeterApp.swift
//  CalorieMeter
//
//  Created by Pavel Klopat on 18.11.25.
//

import SwiftUI

@main
struct CalorieMeterApp: App {
    let coreDataStoreManager = CoreDataManager()

    var body: some Scene {
        WindowGroup {
            ProductsListView(context: coreDataStoreManager.container.viewContext)
                .environment(\.managedObjectContext, coreDataStoreManager.container.viewContext)
        }
    }
}
