//
//  AnyDirectory.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-20.
//

import SwiftUI

public struct AnyDirectory {
    let root: URL
    let contents: [URL]
//    let contentSizes: [URL: Int]
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
        
        Task { @MainActor in
            self.directory = .init(root: url, contents: contents)
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
                        NavigationLink {
                            AnyDirectoryView(dirUrl: value)
                        } label: {
                            Text("\(value.lastPathComponent)")
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
