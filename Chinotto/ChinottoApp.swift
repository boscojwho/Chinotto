//
//  ChinottoApp.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-12.
//

import SwiftUI
import SwiftData
import CoreSimulatorTools

@main
struct ChinottoApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(maxWidth: 1440)
        }
        .defaultPosition(.center)
        .defaultSize(width: 1080, height: 1080)
        .windowResizability(.contentSize)
        .modelContainer(sharedModelContainer)
        
        WindowGroup(Text("Core Simulators"), id: "CoreSimulators", for: CoreSimulator_User.self) { value in
            CoreSimulatorsRootView()
        }
    }
}
