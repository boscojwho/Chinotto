//
//  Subdirectories.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-14.
//

import Foundation

enum DirectoryScope {
    case system
    case user
}

protocol CoreSimulator {
    var directoryScope: DirectoryScope { get }
    var dirName: String { get }
    var dirDescription: String { get }
}

/// `/Users/{username}/Library/Developer/CoreSimulator`
enum CoreSimulator_User: CoreSimulator, CaseIterable, Identifiable, Codable {
    case caches
    case devices
    case temp
    
    var id: String { dirName }
    
    var directoryScope: DirectoryScope { .user }
    var dirName: String {
        switch self {
        case .caches:
            "Caches"
        case .devices:
            "Devices"
        case .temp:
            "Temp"
        }
    }
    var dirPath: String {
        "\(Self.basePath)/\(dirName)"
    }
    var dirDescription: String {
        switch self {
        case .caches:
            "This is where the Dynamic Linker for various simulator runtimes are stored (e.g. iOS, watchOS, tvOS)."
        case .devices:
            "This is where all the simulator devices that have been downloaded are stored, and typically consumes the most storage space."
        case .temp:
            "Temporary files associated with any simulators are stored here. This directory doesn't appear to contain anything of much permanent interest."
        }
    }
    
    static var basePath: String {
        "/Users/\(NSUserName())/Library/Developer/CoreSimulator"
    }
}

/// `/Library/Developer/CoreSimulator`
enum CoreSimulator_System: CoreSimulator, CaseIterable, Identifiable {
    case caches
    case cryptex
    case images
    case volumes
    
    var id: String { dirName }
    
    var directoryScope: DirectoryScope { .system }
    var dirName: String {
        switch self {
        case .caches:
            "Caches"
        case .cryptex:
            "Cryptex"
        case .images:
            "Images"
        case .volumes:
            "Volumes"
        }
    }
    var dirDescription: String {
        switch self {
        case .caches:
            ""
        case .cryptex:
            ""
        case .images:
            ""
        case .volumes:
            ""
        }
    }
}

enum Xcode_User: CaseIterable, Identifiable {
    /// `~/Xcode/UserData`
    case userData
    
    var id: String { dirName }
    
    var dirName: String {
        switch self {
        case .userData:
            return "UserData"
        }
    }
    var dirPath: String {
        "\(Self.basePath)/\(dirName)"
    }
    var dirDescription: String {
        switch self {
        case .userData:
            return ""
        }
    }
        
    static var basePath: String {
        "/Users/\(NSUserName())/Library/Developer/Xcode"
    }
}
