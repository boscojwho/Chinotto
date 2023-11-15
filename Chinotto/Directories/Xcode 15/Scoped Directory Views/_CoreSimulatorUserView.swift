//
//  _CoreSimulatorUserView.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-14.
//

import SwiftUI

struct _CoreSimulatorUserView: View {
    
    @State private var storageViewModel: StorageViewModel = .init(directory: .coreSimulator)
    @State private var showInspectorView = false
    @State private var inspectorData: CoreSimulator_User?
    
    @State private var selectedFiles: Set<SizeMetadata.ID> = .init()
    @State private var selectedDirs: Set<SizeMetadata.ID> = .init()
    
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
                        NavigationLink(value: value) {
                            GroupBox {
                                VStack {
                                    HStack {
                                        Text("/\(value.dirName)")
                                            .fontWeight(.bold)
                                        Spacer()
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
                        .onTapGesture {
                            inspectorData = value
                            showInspectorView = true
                        }
                    }
                }
            }
            .listStyle(.inset)
            
            Table(
                storageViewModel.fileSizeMetadata,
                selection: $selectedFiles
            ) {
                TableColumn("Size", value: \.value)
                TableColumn("File", value: \.key.lastPathComponent)
            }
            .contextMenu {
                Button {
                    showFilesInFinder()
                } label: {
                    Text("Show in Finder")
                }
                .disabled(selectedFiles.isEmpty)
            }

            Table(
                storageViewModel.dirSizeMetadata,
                selection: $selectedDirs
            ) {
                TableColumn("Size", value: \.value)
                TableColumn("Directory", value: \.key.lastPathComponent)
            }
            .contextMenu {
                Button {
                    showDirsInFinder()
                } label: {
                    Text("Show in Finder")
                }
                .disabled(selectedDirs.isEmpty)
            }
        }
        .inspector(isPresented: $showInspectorView) {
            makeInspectorView()
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
    
    @ViewBuilder
    private func makeInspectorView() -> some View {
        if let inspectorData {
            switch inspectorData {
            case .caches:
                Text("")
            case .devices:
                @Bindable var vm = storageViewModel
                _CoreSimulatorDevicesView(dirScope: .user, storageViewModel: $vm)
                    .inspectorColumnWidth(min: 320, ideal: 600)
            case .temp:
                Text("")
            }
        } else {
            Text("Select directory data.")
        }
    }
}

#Preview {
    _CoreSimulatorUserView()
}
