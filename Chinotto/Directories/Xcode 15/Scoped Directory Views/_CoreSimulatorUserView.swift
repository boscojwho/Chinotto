//
//  _CoreSimulatorUserView.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-14.
//

import SwiftUI

struct _CoreSimulatorUserView: View {
    
    @Environment(\.openWindow) var openWindow
    
    @State private var storageViewModel: StorageViewModel = .init(directory: .coreSimulator)
    
    var body: some View {
        VSplitView {
            List {
                Section {
                    EmptyView()
                } header: {
                    Text("/CoreSimulator")
                }
                
                StorageView(viewModel: storageViewModel)
                
                ForEach(CoreSimulator_User.allCases) { value in
                    Section {
                        GroupBox {
                            VStack {
                                HStack {
                                    Text("/\(value.dirName)")
                                        .fontWeight(.bold)
                                    Spacer()
                                    if value == .devices {
                                        Button("Inspect Devices...") {
                                            openWindow(id: "CoreSimulators", value: value)
                                        }
                                        .tint(.accentColor)
                                        .buttonStyle(.borderedProminent)
                                    } else {
                                        Button("Show in Finder") {
                                            let url = URL(filePath: value.dirPath, directoryHint: .isDirectory)
                                            NSWorkspace.shared.activateFileViewerSelecting([url])
                                        }
                                    }
                                }
                                Divider()
                                HStack {
                                    Text("\(value.dirDescription)")
                                        .fontWeight(.medium)
                                    Spacer()
                                }
                            }
                            .padding(2)
                        }
                    }
                }
            }
            .listStyle(.inset)
        }
    }
}

#Preview {
    _CoreSimulatorUserView()
}
