//
//  CoreSimulatorView.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-14.
//

import SwiftUI

struct CoreSimulatorView: View {
    
    /// The /CoreSimulator directory to show.
    ///
    /// Each scope's file contents are different.
    let directoryScope: DirectoryScope
    
    var body: some View {
        switch directoryScope {
        case .system:
            _CoreSimulatorSystemView()
        case .user:
            _CoreSimulatorUserView()
        }
    }
}

#Preview {
    CoreSimulatorView(directoryScope: .user)
}
