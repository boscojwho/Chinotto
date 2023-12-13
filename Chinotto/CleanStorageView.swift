//
//  CleanStorageView.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-12-12.
//

import SwiftUI
import DestructiveActions

struct CleanStorageView: View {
    
    @AppStorage("preferences.general.deletionBehaviour") var deletionBehaviour: DeletionBehaviour = .moveToTrash
    
    @Binding var directory: Directories?
    @State private var viewModel: StorageViewModel?
    
    var body: some View {
        Group {
            if let viewModel {
                cleanView(viewModel: viewModel)
            } else {
                loadingView()
            }
        }
        .onChange(of: directory, initial: true) { oldValue, newValue in
            if let newValue {
                viewModel = .init(directory: newValue)
            }
        }
    }
    
    private func cleanView(viewModel: StorageViewModel) -> some View {
        Text("\(viewModel.directory.dirName)")
    }
    
    private func loadingView() -> some View {
        GroupBox {
            ProgressView()
        }
    }
}

#Preview {
    CleanStorageView(directory: .constant(.developerDiskImages))
}
