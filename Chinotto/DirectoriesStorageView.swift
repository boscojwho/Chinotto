//
//  DirectoriesStorageView.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-13.
//

import SwiftUI

/// Shows the storage consumed for each directory, separately.
struct DirectoriesStorageView: View {
    
    @State private var viewModels: [StorageViewModel]
    
    init() {
        let viewModels = Directories.allCases.map {
            StorageViewModel(directory: $0)
        }
        _viewModels = .init(wrappedValue: viewModels)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12, pinnedViews: .sectionHeaders) {
                Section {
                    UnifiedStorageView(viewModels: $viewModels)
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
                    ForEach(viewModels) { value in
                        StorageView(viewModel: value)
                            .contextMenu {
                                Button("Show in Finder") {
                                    let url = URL(filePath: value.directory.path, directoryHint: .isDirectory)
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
