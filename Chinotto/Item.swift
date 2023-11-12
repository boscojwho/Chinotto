//
//  Item.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-12.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
