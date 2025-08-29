//
//  NextSetApp.swift
//  NextSet
//
//  Created by Christian Dees on 8/28/25.
//

import SwiftUI

@main
struct NextSetApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }

    }
}

