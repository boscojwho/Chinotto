//
//  ChinottoMenuBarApp.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-28.
//

import SwiftUI

struct ChinottoMenuBarApp: View {
    
    @State private var directories: [StorageViewModel] = [
        .init(directory: .coreSimulator),
        .init(directory: .developerDiskImages),
        .init(directory: .toolchains),
        .init(directory: .xcPGDevices),
        .init(directory: .xcTestDevices),
        .init(directory: .xcode),
    ]
    
    var body: some View {
        DirectoriesStorageView(viewModels: $directories)
            .frame(width: 480, height: 720)
            .environment(\.horizontalSizeClass, .compact)
    }
}
