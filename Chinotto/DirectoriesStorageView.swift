//
//  DirectoriesStorageView.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-13.
//

import SwiftUI

struct DirectoriesStorageView: View {
    var body: some View {
        ScrollView {
            LazyVStack(pinnedViews: .sectionHeaders) {
                Section {
                    ForEach(Directories.allCases) { value in
                        GroupBox {
                            StorageView(directory: value)
                        }
                    }
                } header: {
                    GroupBox {
                        HStack {
                            Text("By Directory")
                        }
                    }
                    .background(.regularMaterial)
                }
            }
        }
        .contentMargins(8)
    }
}

#Preview {
    DirectoriesStorageView()
}
