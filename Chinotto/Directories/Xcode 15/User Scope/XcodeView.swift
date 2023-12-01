//
//  XcodeView.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-14.
//

import SwiftUI

struct XcodeView: View {
    
    @State private var storageViewModel: StorageViewModel = .init(directory: .xcode)
    
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
                    Text("Xcode.app related directories.")
                }
                
                ForEach(Xcode_User.allCases) { value in
                    Section {
                        GroupBox {
                            VStack {
                                HStack {
                                    Text("/\(value.dirName)")
                                        .fontWeight(.bold)
                                    Spacer()
                                    Button("Show in Finder") {
                                        let url = URL(filePath: value.dirPath, directoryHint: .isDirectory)
                                        NSWorkspace.shared.activateFileViewerSelecting([url])
                                    }
                                    if value == .userData {
                                        Button("Inspect code snippets...") {
                                            
                                        }
                                        .tint(.accentColor)
                                        .buttonStyle(.borderedProminent)
                                    }
                                }
                                Divider()
                                HStack {
                                    Text("\(value.dirDescription)")
                                        .fontWeight(.medium)
                                    Spacer()
                                }
                            }
                        }
                    }
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
    XcodeView()
}
