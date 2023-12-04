//
//  AppDelegate.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-12-04.
//

import Foundation
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var openAtLogin: Bool {
        UserDefaults.standard.bool(forKey: "openAtLogin")
    }
    
    private var hideWindowsOnLaunch: Bool {
        UserDefaults.standard.bool(forKey: "hideWindowsOnLaunch")
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        for window in NSApplication.shared.windows {
            if openAtLogin == true,
               hideWindowsOnLaunch == true,
               let isDefaultLaunch = notification.userInfo?[NSApplication.launchIsDefaultUserInfoKey] as? Bool,
               isDefaultLaunch == false {
                /// Menu bar app window and menu bar item window aren't restorable.
                if window.isRestorable {
                    window.close()
                }
            }
        }
    }
}
