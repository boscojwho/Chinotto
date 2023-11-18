//
//  XcodeVersion.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-17.
//

import Foundation

enum XcodeVersion: String, CaseIterable, CustomStringConvertible, Identifiable {
    case v15
    
    var description: String {
        switch self {
        case .v15:
            "Xcode 15"
        }
    }
    
    var id: Self {
        self
    }
    
    /// The default version for any given year.
    static var `default`: XcodeVersion {
        .v15
    }
}
