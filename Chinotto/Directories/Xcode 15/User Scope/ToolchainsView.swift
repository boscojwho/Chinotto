//
//  ToolchainsView.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-14.
//

import SwiftUI
import SwiftData

struct ToolchainsView: View {
    
    @Query var filesMetadata: [SizeMetadata]
    @Query var dirsMetadata: [SizeMetadata]
    
    @State private var storageViewModel: StorageViewModel = .init(directory: .toolchains)
    
    @State private var selectedFiles: Set<SizeMetadata.ID> = .init()
    @State private var selectedDirs: Set<SizeMetadata.ID> = .init()

    var body: some View {
        VSplitView {
            List {
                Section {
                    EmptyView()
                } header: {
                    Text("/\(storageViewModel.directory.dirName)")
                }
                
                StorageView(viewModel: storageViewModel)
            }
            .listStyle(.inset)
            
            Table(
                try! filesMetadata.filter(#Predicate { input in
                    input.key.pathComponents.contains(where: { p in p == "Toolchains" }) && !input.key.hasDirectoryPath
                }),
                selection: $selectedDirs
            ) {
                TableColumn("Size", value: \.value)
                TableColumn("File", value: \.key.lastPathComponent)
            }
            .contextMenu {
                Button {
                    showFilesInFinder()
                } label: {
                    Text("Show in Finder")
                }
                .disabled(selectedFiles.isEmpty)
            }
            
            Table(
                try! dirsMetadata.filter(#Predicate { input in
                    input.key.pathComponents.contains(where: { p in p == "Toolchains" }) && input.key.hasDirectoryPath
                }),
                selection: $selectedFiles
            ) {
                TableColumn("Size", value: \.value)
                TableColumn("File", value: \.key.lastPathComponent)
            }
            .contextMenu {
                Button {
                    showDirsInFinder()
                } label: {
                    Text("Show in Finder")
                }
                .disabled(selectedDirs.isEmpty)
            }
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
