//
//  DeviceIdiom.swift
//
//
//  Created by Bosco Ho on 2023-11-17.
//

import Foundation

/// Same as `UIUserInterfaceIdiom`.
public enum DeviceIdiom: Int, Sendable, CustomStringConvertible, Comparable {
    public static func < (lhs: DeviceIdiom, rhs: DeviceIdiom) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
    
    case unspecified
    case phone
    case pad
    case watch
    case tv
    case carPlay
    case mac
    case vision
    
    public var id: Int { rawValue }
    
    public var description: String {
        switch self {
        case .unspecified:
            "Unspecified"
        case .phone:
            "Phone"
        case .pad:
            "Pad"
        case .watch:
            "Watch"
        case .tv:
            "TV"
        case .carPlay:
            "CarPlay"
        case .mac:
            "Mac"
        case .vision:
            "Vision"
        }
    }
    
    public var systemImage: String {
        switch self {
        case .unspecified:
            "questionmark.app"
        case .phone:
            "apps.iphone"
        case .pad:
            "apps.ipad.landscape"
        case .watch:
            "applewatch"
        case .tv:
            "tv"
        case .carPlay:
            "car"
        case .mac:
            "macbook"
        case .vision:
            "visionpro"
        }
    }
}

extension DeviceIdiom {
    static func idiom(for device: DevicePlist) -> Self {
        let deviceName = device.name
        if deviceName.localizedCaseInsensitiveContains("phone") || deviceName.localizedCaseInsensitiveContains("pod") {
            return .phone
        } else if deviceName.localizedCaseInsensitiveContains("pad") {
            return .pad
        } else if deviceName.localizedCaseInsensitiveContains("watch") {
            return .watch
        } else if deviceName.localizedCaseInsensitiveContains("tv") {
            return .tv
        } else if deviceName.localizedCaseInsensitiveContains("carplay") {
            return .carPlay
        } else if deviceName.localizedCaseInsensitiveContains("mac") {
            return .mac
        } else if deviceName.localizedCaseInsensitiveContains("vision") {
            return .vision
        } else {
            return .unspecified
        }
    }
}
