//
//  DirectoriesStorageView.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-13.
//

import SwiftUI

/// Shows the storage consumed for each directory, separately.
struct DirectoriesStorageView: View {
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12, pinnedViews: .sectionHeaders) {
                Section {
                    UnifiedStorageView()
                } header: {
                    HStack {
                        Text("All Directories")
                            .fontWeight(.medium)
                            .padding(8)
                    }
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                
                Divider()
                
                Section {
                    ForEach(Directories.allCases) { value in
                        GroupBox {
                            StorageView(directory: value)
                        }
                        .contextMenu {
                            Button("Show in Finder") {
                                let url = URL(filePath: value.path, directoryHint: .isDirectory)
                                NSWorkspace.shared.activateFileViewerSelecting([url])
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("By Directory")
                            .fontWeight(.medium)
                            .padding(8)
                    }
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
        }
        .contentMargins(8)
    }
}

#Preview {
    DirectoriesStorageView()
}
