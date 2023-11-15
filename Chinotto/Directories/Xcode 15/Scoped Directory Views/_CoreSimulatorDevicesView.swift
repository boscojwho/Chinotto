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
                    return CoreSimulatorDevice(uuid: uuid, plist: devicePlist, data: dataDir)
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
        List {
            ForEach(devicesViewModel.devices) { value in
                GroupBox {
                    Text("\(value.devicePlist?.name ?? value.uuid.uuidString)")
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
        .task {
            devicesViewModel.loadDevices()
        }
    }
}

#Preview {
    _CoreSimulatorDevicesView(
        dirScope: .user,
        storageViewModel: .init(.init(directory: .developerDiskImages))
    )
}
