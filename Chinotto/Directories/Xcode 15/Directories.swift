//
//  Directories.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-12.
//

import Foundation
import SwiftUI
import Charts
import FileSystem

/// A non-exhaustive list of top-level directories in `/Developer`.
enum Directories: CaseIterable, Identifiable, Codable {
    case coreSimulator
    case developerDiskImages
    case toolchains
    
    case xcode
    case xcPGDevices
    case xcTestDevices
    
    var id: String { dirName }
    
    /// Base path for `/Developer` directory in current user's directory.
    static var userBasePath: String {
        "/Users/\(NSUserName())/Library/Developer"
    }
    
    /// Base path for `/Developer` directory not associated with any user.
    static var systemBasePath: String {
        "/Library/Developer"
    }
    
    var dirName: String {
        switch self {
        case .coreSimulator:
            "CoreSimulator"
        case .developerDiskImages:
            "DeveloperDiskImages"
        case .toolchains:
            "Toolchains"
        case .xcode:
            "Xcode"
        case .xcPGDevices:
            "XCPGDevices"
        case .xcTestDevices:
            "XCTestDevices"
        }
    }
    
    var path: String {
        "\(Self.userBasePath)/\(dirName)"
    }
    
    var systemPath: String {
        "\(Self.systemBasePath)/\(dirName)"
    }
    
    func path(scope: DirectoryScope) -> String {
        switch scope {
        case .system:
            systemPath
        case .user:
            path
        }
    }
    
    var systemImage: String {
        switch self {
        case .coreSimulator:
            "apps.iphone"
        case .developerDiskImages:
            "externaldrive.fill"
        case .toolchains:
            "screwdriver"
        case .xcode:
            "wrench.and.screwdriver.fill"
        case .xcPGDevices:
            "circle.filled.iphone"
        case .xcTestDevices:
            "circle.filled.iphone.fill"
        }
    }
}

extension Directories {
    
    var accentColor: Color {
        switch self {
        case .coreSimulator:
            Color.orange
        case .developerDiskImages:
            Color.purple
        case .toolchains:
            .teal
        case .xcode:
            Color.blue
        case .xcPGDevices:
            Color.pink
        case .xcTestDevices:
            Color.mint
        }
    }
}

extension Directories: Plottable {
    var primitivePlottable: String {
        dirName
    }
    
    init?(primitivePlottable: String) {
        if let match = Directories.allCases.first(where: { $0.dirName == primitivePlottable }) {
            self = match
        } else {
            return nil
        }
    }
    
    typealias PrimitivePlottable = String
    
    
}
