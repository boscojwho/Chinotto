//
//  ToolchainsView.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-14.
//

import SwiftUI

struct ToolchainsView: View {
    
    @State private var storageViewModel: StorageViewModel = .init(directory: .toolchains)
    
    @State private var selectedFiles: Set<SizeMetadata.ID> = .init()
    @State private var selectedDirs: Set<SizeMetadata.ID> = .init()

    var body: some View {
        VSplitView {
            List {
                Section {
                    Button("Show in Finder") {
                        let url = URL(filePath: storageViewModel.directory.path(scope: .user), directoryHint: .isDirectory)
                        NSWorkspace.shared.activateFileViewerSelecting([url])
                    }
                } header: {
                    Text("/\(storageViewModel.directory.dirName)")
                }
                
                StorageView(viewModel: storageViewModel)
                
                Section("Description") {
                    Text("Recommended: Manage Toolchains using Xcode's built-in tool (Xcode > Toolchains > Manage Toolchains...).")
                }
            }
            .listStyle(.inset)
        }
    }
    
    private func showFilesInFinder() {
        let filePaths = selectedFiles
        let fileUrls = filePaths.compactMap { URL(string: $0 ) }
        NSWorkspace.shared.activateFileViewerSelecting(fileUrls)
    }
    
    private func showDirsInFinder() {
        let dirPaths = selectedDirs
        let dirUrls = dirPaths.compactMap { URL(string: $0 ) }
        NSWorkspace.shared.activateFileViewerSelecting(dirUrls)
    }
}

#Preview {
    ToolchainsView()
}
