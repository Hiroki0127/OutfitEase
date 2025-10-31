//
//  outfitEaseApp.swift
//  outfitEase
//
//  Created by Hiroki Mukai on 2025-10-31.
//

import SwiftUI

@main
struct outfitEaseApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
