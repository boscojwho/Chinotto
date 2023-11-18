//
//  DeveloperDiskImagesView.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-14.
//

import SwiftUI

struct SizeMetadata: Identifiable {
    var id: String { key.absoluteString }
    
    let key: URL
    let value: String
}

struct DeveloperDiskImagesView: View {
    
    @State private var storageViewModel: StorageViewModel = .init(directory: .developerDiskImages)
    
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
                
                ForEach(storageViewModel.dirMetadata.sorted(by: { lhs, rhs in lhs.value > rhs.value }), id: \.key) { key, value in
                    GroupBox {
                        Text("\(key.lastPathComponent) - \(value)")
                            .font(.footnote)
                    }
                }
                
                Section("Description") {
                    Text("Manually managing this directory is not recommended.")
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
    DeveloperDiskImagesView()
}
