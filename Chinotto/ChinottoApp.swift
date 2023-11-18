//
//  ChinottoApp.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-12.
//

import SwiftUI
import CoreSimulatorTools

@main
struct ChinottoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(maxWidth: 1440)
        }
        .defaultPosition(.center)
        .defaultSize(width: 840, height: 1080)
        .windowResizability(.contentSize)
        /// [2023.11] Feature exists in another branch.
//        .modelContainer(sharedModelContainer)
        
        WindowGroup(Text("Core Simulators"), id: "CoreSimulators", for: CoreSimulator_User.self) { value in
            CoreSimulatorsRootView()
        }
    }
}
