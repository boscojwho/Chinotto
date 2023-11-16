//
//  _CoreSimulatorDevicesView.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-15.
//

import SwiftUI
import CoreSimulatorTools

@Observable
final class CoreSimulatorDevicesViewModel {
    let directory: Directories
    let dirScope: DirectoryScope
    init(directory: Directories, dirScope: DirectoryScope) {
        self.directory = directory
        self.dirScope = dirScope
    }
    
    var devices: [CoreSimulatorDevice] = []
    
    func loadDevices() {
        let path = directory.path(scope: dirScope)
        let url = URL(string: path)!.appending(path: "Devices", directoryHint: .isDirectory)
        
        let contents: [URL]
        do {
            contents = try FileManager.default.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [.isRegularFileKey, .isDirectoryKey],
                options: [.skipsPackageDescendants, .skipsHiddenFiles]
            )
            
            let devices: [CoreSimulatorDevice] = try contents.compactMap { deviceDir in
                guard deviceDir.hasDirectoryPath else { return nil }

                let deviceContents = try FileManager.default.contentsOfDirectory(
                    at: deviceDir,
                    includingPropertiesForKeys: [.isRegularFileKey, .isDirectoryKey],
                    options: [.skipsPackageDescendants, .skipsHiddenFiles]
                )
                
                let devicePlist = deviceContents.first { $0.lastPathComponent == "device.plist" }
                let dataDir = deviceContents.first { $0.lastPathComponent == "data" }
                if let devicePlist, let dataDir, let uuid = UUID(uuidString: deviceDir.lastPathComponent) {
                    return CoreSimulatorDevice(root: deviceDir, uuid: uuid, plist: devicePlist, data: dataDir)
                } else {
                    return nil
                }
            }
            
            self.devices = devices
        } catch {
            print(error)
        }
    }
}

struct _CoreSimulatorDevicesView: View {
    
    @Environment(\.openWindow) var openWindow
    
    @Bindable var storageViewModel: StorageViewModel
    @State private var devicesViewModel: CoreSimulatorDevicesViewModel
    
    @State private var selectedDevices: Set<CoreSimulatorDevice.ID> = .init()
    @State private var tableSortOrder = [KeyPathComparator(\CoreSimulatorDevice.totalSize)]
    
    init(dirScope: DirectoryScope, storageViewModel: Bindable<StorageViewModel>) {
        _devicesViewModel = .init(
            wrappedValue: .init(
                directory: .coreSimulator,
                dirScope: dirScope
            )
        )
        _storageViewModel = storageViewModel
    }
    
    var body: some View {
        tableView()
            .task {
                devicesViewModel.loadDevices()
            }
    }
    
    @ViewBuilder
    private func tableView() -> some View {
        Table(
            devicesViewModel.devices,
            selection: $selectedDevices,
            sortOrder: $tableSortOrder
        ) {
            TableColumn("Device Name", value: \.name) { value in
                HStack {
                    Text(value.name)
                    Spacer()
                    Image(systemName: "chevron.forward")
                        .foregroundStyle(.secondary)
                        .onTapGesture {
                            openWindow(id: "CoreSimulatorDevice", value: value)
                        }
                }
            }
            TableColumn("Size", value: \.totalSize) { value in
                if let totalSize = value.size {
                    Text("\(ByteCountFormatter.string(fromByteCount: Int64(totalSize), countStyle: .file))")
                } else {
                    ProgressView()
                        .controlSize(.small)
                }
            }
        }
        .contextMenu(
            forSelectionType: CoreSimulatorDevice.ID.self) { items in
                // no-op.
            } primaryAction: { deviceIds in
                for id in deviceIds {
                    if let device = devicesViewModel.devices.first(where: { $0.id == id }) {
                        openWindow(id: "CoreSimulatorDevice", value: device)
                    }
                }
            }
        .onChange(of: tableSortOrder) { _, sortOrder in
            devicesViewModel.devices.sort(using: sortOrder)
        }
    }
    
    @ViewBuilder
    private func listView() -> some View {
        List {
            ForEach(devicesViewModel.devices) { value in
                GroupBox {
                    HStack {
                        Text("\(value.devicePlist?.name ?? value.uuid.uuidString)")
                        if let metadata = value.dataContents?.metadata {
                            let totalSize = metadata.reduce(0) { $0 + $1.size }
                            Text("[\(ByteCountFormatter.string(fromByteCount: Int64(totalSize), countStyle: .file))]")
                        }
                    }
                }
                .containerRelativeFrame(.horizontal)
                .onTapGesture {
                    /// Open new window for device.
                    value.dirsMetadata = storageViewModel.dirMetadata
                    value.filesMetadata = storageViewModel.fileMetadata
                    openWindow(id: "CoreSimulatorDevice", value: value)
                }
            }
        }
    }
}

#Preview {
    _CoreSimulatorDevicesView(
        dirScope: .user,
        storageViewModel: .init(.init(directory: .developerDiskImages))
    )
}
