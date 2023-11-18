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
        
        WindowGroup(Text("Core Simulator (Devices)"), id: "CoreSimulators", for: CoreSimulator_User.self) { value in
            CoreSimulatorsRootView()
        }
        .defaultPosition(.topLeading)
        .defaultSize(width: 1440, height: 1080)
        
        WindowGroup(Text("Xcode Playground Devices (XCPGDevices)"), id: "XCPGDevices", for: Directories.self) { value in
            if let dir = value.wrappedValue, dir == .xcPGDevices {
                XCPGDevicesRootView()
            }
        }
        .defaultPosition(.topLeading)
        .defaultSize(width: 1440, height: 1080)
    }
}
