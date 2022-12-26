//
//  Bluetooth_FinderApp.swift
//  Bluetooth Finder
//
//  Created by Gabriel Busto on 12/24/22.
//

import SwiftUI

@main
struct Bluetooth_FinderApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
