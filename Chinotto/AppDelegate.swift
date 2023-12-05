//
//  AppDelegate.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-12-04.
//

import Foundation
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        LoginItemBehaviour.hideWindowsOnDidFinishLaunching(
            NSApplication.shared.windows,
            notification
        )
    }
}
