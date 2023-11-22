//
//  DeletionBehaviour.swift
//
//
//  Created by Bosco Ho on 2023-11-21.
//

import Foundation
import SwiftUI

public enum DeletionBehaviour: Int, CaseIterable, CustomStringConvertible, Identifiable {
    case moveToTrash
    case permanent
    
    public var description: String {
        switch self {
        case .moveToTrash:
            "Move to Trash"
        case .permanent:
            "Permanently Delete"
        }
    }
    
    public var behaviourDescription: String {
        switch self {
        case .moveToTrash:
            "Deleted items are moved to Trash, where you may recover items, if needed."
        case .permanent:
            "Warning: Recovery is not possible with this option. Deleted items are permanently removed from file system."
        }
    }
    
    public var systemImage: String {
        switch self {
        case .moveToTrash:
            "trash"
        case .permanent:
            "exclamationmark.circle"
        }
    }
    
    public var accentColor: Color {
        switch self {
        case .moveToTrash:
            Color.orange
        case .permanent:
            Color.red
        }
    }
    
    public var id: Int { rawValue }
}
