//
//  _XcodeCleanStorageView.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-12-12.
//

import SwiftUI
import FileSystemUI

struct DirectoryDisclosureView: View {
    
    @State private var viewModel: AnyDirectoryViewModel
    
    init(url: URL) {
        _viewModel = .init(wrappedValue: .init(url: URL(string: Directories.xcode.userPath)!))
    }
    
    var body: some View {
        Group {
            if let directory = viewModel.directory {
                ForEach(directory.contents, id: \.self) { value in
                    DisclosureGroup {
                        Text("Contents")
                    } label: {
                        Toggle(isOn: .constant(false)) {
                            Text("\(value.lastPathComponent) (\(directory.contentSizes[value] ?? -1)")
                        }
                        .toggleStyle(.checkbox)
                    }
                }
                .pickerStyle(.radioGroup)
            }
        }
    }
}

struct _XcodeCleanStorageView: View {
    
    @State private var viewModel: AnyDirectoryViewModel = .init(url: URL(string: Directories.xcode.userPath)!)
    
    var body: some View {
        List {
            if let directory = viewModel.directory {
                ForEach(directory.contents, id: \.self) { value in
                    DisclosureGroup {
                        DirectoryDisclosureView(url: value)
                    } label: {
                        Toggle(isOn: .constant(false)) {
                            Text("\(value.lastPathComponent) (\(directory.contentSizes[value] ?? -1))")
                        }
                        .toggleStyle(.checkbox)
                    }
                }
            }
        }
        .task {
            try? viewModel.loadContents()
        }
    }
}

#Preview {
    _XcodeCleanStorageView()
}
