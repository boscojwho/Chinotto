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
        }
        .modelContainer(sharedModelContainer)
        
        WindowGroup(Text("Core Simulator Device"), id: "CoreSimulatorDevice", for: CoreSimulatorDevice.self) { value in
            CoreSimDeviceView(device: value)
        }
    }
}
