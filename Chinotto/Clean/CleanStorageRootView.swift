//
//  CleanStorageRootView.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-12-12.
//

import SwiftUI

struct CleanStorageRootView: View {
    
    @Binding var directory: Directories?
    
    var body: some View {
        if let directory {
            switch directory {
            case .coreSimulator:
                CoreSimulatorsRootView()
            case .xcode:
                _XcodeCleanStorageView()
            default:
                CleanStorageView(directory: $directory)
            }
        } else {
            CleanStorageView(directory: $directory)
        }
    }
}

#Preview {
    CleanStorageRootView(directory: .constant(.developerDiskImages))
}
