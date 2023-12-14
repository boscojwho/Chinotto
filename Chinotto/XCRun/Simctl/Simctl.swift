//
//  Simctl.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-12-14.
//

import Foundation

protocol ShellCommand {
    var executableURL: URL { get }
    var args: [String] { get }
}

extension XCRun {
    struct Simctl {}
}

extension XCRun.Simctl {
    struct DeleteUnavailable: ShellCommand {
        let executableURL: URL = .init(filePath: "/usr/bin/xcrun")
        let args: [String] = ["simctl", "delete", "unavailable"]
    }
}
