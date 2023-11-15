//
//  CachesView.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-14.
//

import SwiftUI

struct CachesView: View {
    
    let directory: CoreSimulator
    
    var body: some View {
        switch directory.directoryScope {
        case .system:
            _CoreSimulatorSystemCachesView()
        case .user:
            _CoreSimulatorUserCachesView()
        }
    }
}

#Preview {
    CachesView(directory: CoreSimulator_User.caches)
}
