//
//  AnyDirectory.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-20.
//

import SwiftUI
import FileSystem

public struct AnyDirectory {
    let root: URL
    let contents: [URL]
    let contentSizes: [URL: Int]
}

@Observable
public final class AnyDirectoryViewModel {
    public let url: URL
    public init(url: URL) {
        self.url = url
    }
    
    public var isLoading = false
    public var directory: AnyDirectory?
    
    public func loadContents() throws {
        defer {
            Task { @MainActor in
                isLoading = false
            }
        }
        let contents = try FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey, .creationDateKey, .contentModificationDateKey],
            options: [.skipsPackageDescendants, .skipsHiddenFiles]
        )
        
        let sizes = contents.compactMap {
            if $0.hasDirectoryPath {
                return ($0, URL.directorySize(url: $0))
            } else {
                if let values = try? $0.resourceValues(forKeys: [.fileSizeKey]) {
                    let size = values.fileSize ?? 0
                    return ($0, size)
                } else {
                    return ($0, 0)
                }
            }
        }
        let grouped = Dictionary(grouping: sizes, by: { $0.0 })
            .compactMapValues { e in e.reduce(0) { $0 + $1.1 } }
        
        Task { @MainActor in
            self.directory = .init(root: url, contents: contents, contentSizes: grouped)
            self.isLoading = false
        }
    }
}

public struct AnyDirectoryView: View {
    
    public init(dirUrl: URL) {
        _viewModel = .init(wrappedValue: .init(url: dirUrl))
    }
    
    @State private var viewModel: AnyDirectoryViewModel
    
    public var body: some View {
        List {
            if let directory = viewModel.directory {
                if directory.contents.isEmpty {
                    GroupBox {
                        Text("Empty Directory")
                    }
                } else {
                    ForEach(directory.contents, id: \.self) { value in
                        if value.hasDirectoryPath {
                            NavigationLink {
                                AnyDirectoryView(dirUrl: value)
                            } label: {
                                HStack {
                                    Text("\(value.lastPathComponent)")
                                    if let size = directory.contentSizes[value] {
                                        Text("\(ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file))")
                                    }
                                }
                            }
                        } else {
                            HStack {
                                Text("\(value.lastPathComponent)")
                                if let size = directory.contentSizes[value] {
                                    Text("\(ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file))")
                                }
                            }
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
        .task {
            try? viewModel.loadContents()
        }
    }
}
