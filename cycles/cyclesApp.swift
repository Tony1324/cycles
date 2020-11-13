//
//  cyclesApp.swift
//  cycles
//
//  Created by Tony Zhang on 11/12/20.
//

import SwiftUI

@main
struct cyclesApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
