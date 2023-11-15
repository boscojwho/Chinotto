//
//  XCTestDevicesView.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-14.
//

import SwiftUI

struct XCTestDevicesView: View {
    
    @State private var storageViewModel: StorageViewModel = .init(directory: .xcTestDevices)

    var body: some View {
        List {
            Section {
                EmptyView()
            } header: {
                Text("/\(storageViewModel.directory.dirName)")
            }
            
            StorageView(viewModel: storageViewModel)
        }
        .listStyle(.inset)
    }
}

#Preview {
    XCTestDevicesView()
}
