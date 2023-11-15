//
//  DeveloperDiskImagesView.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-14.
//

import SwiftUI
import SwiftData

@Model
final class SizeMetadata: Identifiable {
    var id: String { key.absoluteString }
    
    @Attribute(.unique)
    let key: URL
    let value: String
    
    init(key: URL, value: String) {
        self.key = key
        self.value = value
    }
}

struct DeveloperDiskImagesView: View {
    
    @Query
    var files: [SizeMetadata]
    
    @State private var storageViewModel: StorageViewModel = .init(directory: .developerDiskImages)
    
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
                
                ForEach(storageViewModel.dirMetadata.sorted(by: { lhs, rhs in lhs.value > rhs.value }), id: \.key) { key, value in
                    GroupBox {
                        Text("\(key.lastPathComponent) - \(value)")
                            .font(.footnote)
                    }
                }
            }
            .listStyle(.inset)
            
            Table(
                self.files,
                selection: $selectedFiles
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
                storageViewModel.dirSizeMetadata,
                selection: $selectedDirs
            ) {
                TableColumn("Size", value: \.value)
                TableColumn("Directory", value: \.key.lastPathComponent)
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
    DeveloperDiskImagesView()
}
