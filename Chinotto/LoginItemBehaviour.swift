//
//  LoginItemBehaviour.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-12-04.
//

import Foundation
import AppKit

#if os(macOS)
struct LoginItemBehaviour {
    private static var openAtLogin: Bool {
        UserDefaults.standard.bool(forKey: "openAtLogin")
    }
    
    private static var hideWindowsOnLaunch: Bool {
        UserDefaults.standard.bool(forKey: "hideWindowsOnLaunch")
    }
    
    static func hideWindowsOnDidFinishLaunching(_ windows: [NSWindow], _ notification: Notification) {
        for window in windows {
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
#endif
