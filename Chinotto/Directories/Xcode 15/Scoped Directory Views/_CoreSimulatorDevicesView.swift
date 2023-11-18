//
//  _CoreSimulatorDevicesView.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-15.
//

import SwiftUI
import CoreSimulatorTools
import CoreSimulatorUI

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
        
        let url: URL
        if directory == .coreSimulator {
            url = URL(string: path)!.appending(path: "Devices", directoryHint: .isDirectory)
        } else {
            url = URL(string: path)!
        }
        
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
    
    @State private var isPresentingInspectorViewForDevice = true
    @State private var deviceForInspectorView: CoreSimulatorDevice? = nil
    
    private let dateTimeFormatter: RelativeDateTimeFormatter = .init()
    
    init(dirScope: DirectoryScope, storageViewModel: Bindable<StorageViewModel>) {
        _storageViewModel = storageViewModel
        _devicesViewModel = .init(
            wrappedValue: .init(
                directory: storageViewModel.wrappedValue.directory,
                dirScope: dirScope
            )
        )
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
            devicesViewModel.devices.filter { !$0.isDeleted },
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
            .width(min: 200, ideal: 240, max: .infinity)

            TableColumn("Size", value: \.totalSize) { value in
                if let totalSize = value.size {
                    Text("\(ByteCountFormatter.string(fromByteCount: Int64(totalSize), countStyle: .file))")
                } else {
                    ProgressView()
                        .controlSize(.small)
                }
            }
            .width(min: 100, ideal: 144, max: 144)
            
            TableColumn("Date Added", value: \.creationDate) { value in
                Text("\(dateTimeFormatter.localizedString(for: value.creationDate, relativeTo: Date()))")
            }
            .width(min: 120, ideal: 144, max: 180)

            /// Not very useful, since /tmp directory gets updated often. [2023.11]
//            TableColumn("Last Modified", value: \.contentModificationDate) { value in
//                Text("\(dateTimeFormatter.localizedString(for: value.contentModificationDate, relativeTo: Date()))")
//            }
            
            TableColumn("Last Boot Time", value: \.lastBootedAt) { value in
                if value.lastBootedAt == .distantPast {
                    Text("Never Booted")
                } else {
                    Text("\(dateTimeFormatter.localizedString(for: value.lastBootedAt, relativeTo: Date()))")
                }
            }
            .width(min: 120, ideal: 144, max: 180)
            
            TableColumn("Device Kind", value: \.deviceKind) { value in
                HStack(spacing: 10) {
                    Group {
                        Image(systemName: value.deviceKind.systemImage)
                            .frame(alignment: .trailing)
                    }
                    .frame(width: 12, alignment: .trailing)
                    Text(value.deviceKind.description)
                }
            }
            .width(min: 100, ideal: 144, max: 144)
        }
        .contextMenu(forSelectionType: CoreSimulatorDevice.ID.self) { items in
            // no-op.
        } primaryAction: { deviceIds in
            for id in deviceIds {
                if let device = devicesViewModel.devices.first(where: { $0.id == id }) {
                    isPresentingInspectorViewForDevice = true
                    deviceForInspectorView = device
//                    openWindow(id: "CoreSimulatorDevice", value: device)
                }
            }
        }
        .contextMenu {
            Button {
                let devicesToShow = devicesViewModel.devices.filter { devices in
                    selectedDevices.contains { selected in selected == devices.id }
                }
                let fileUrls = devicesToShow.compactMap { $0.root }
                NSWorkspace.shared.activateFileViewerSelecting(fileUrls)
            } label: {
                Text("Show in Finder")
            }
            .disabled(selectedDevices.isEmpty)
        }
        .onChange(of: tableSortOrder) { _, sortOrder in
            devicesViewModel.devices.sort(using: sortOrder)
        }
        .inspector(isPresented: $isPresentingInspectorViewForDevice) {
            if let deviceForInspectorView {
                /// [2023.11] Using `device.isLoadingDataContents` here triggers SwiftUI recursive loop for some reason.
                CoreSimDeviceView(device: $deviceForInspectorView)
                    .inspectorColumnWidth(min: 480, ideal: 520, max: 720) /// [2023.11] This was crashing on some builds on relaunch (state restoration) for some reason.
            } else {
                GroupBox {
                    Text("Double-click to select a device")
                        .foregroundStyle(.secondary)
                }
            }
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
