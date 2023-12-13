//
//  ChinottoMenuBarApp.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-28.
//

import SwiftUI

struct ChinottoMenuBarApp: View {
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow
    
    @State private var directories: [StorageViewModel] = [
        .init(directory: .coreSimulator),
        .init(directory: .xcode),
        .init(directory: .xcPGDevices),
        .init(directory: .xcTestDevices),
        .init(directory: .developerDiskImages),
        .init(directory: .toolchains),
    ]
    
    var body: some View {
        DirectoriesStorageView(viewModels: $directories)
            .frame(width: 480, height: 720)
            .environment(\.horizontalSizeClass, .compact)
            .safeAreaInset(edge: .top) {
                HStack {
                    Text("Chinotto")
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("Open App...") {
                        openWindow(id: "Main Window")
                        dismissWindow()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.accentColor)
                }
                .padding(8)
                .background(.regularMaterial)
            }
    }
}
