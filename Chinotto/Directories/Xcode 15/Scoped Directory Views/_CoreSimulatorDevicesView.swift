//
//  _CoreSimulatorDevicesView.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-15.
//

import SwiftUI

struct DevicePlist: Codable, Identifiable {
    let UDID: String
    let deviceType: String
    let isDeleted: Bool
    let isEphemeral: Bool
    let name: String
    let runtime: String
    let runtimePolicy: String
    let state: Int
    
    var id: String { UDID }
}

@Observable
final class CoreSimulatorDevice: Identifiable, Codable, Hashable {
    static func == (lhs: CoreSimulatorDevice, rhs: CoreSimulatorDevice) -> Bool {
        lhs.uuid == rhs.uuid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
    
    let uuid: UUID
    let plist: URL
    let data: URL
  
    init(uuid: UUID, plist: URL, data: URL) {
        self.uuid = uuid
        self.plist = plist
        self.data = data
        
        Task {
            await decodePlist()
        }
    }
    
    var devicePlist: DevicePlist?
    
    private func decodePlist() async {
        guard let plistData = FileManager.default.contents(atPath: plist.path()) else {
            return
        }
        
        do {
            let value = try PropertyListDecoder().decode(DevicePlist.self, from: plistData)
            Task { @MainActor in
                devicePlist = value
            }
        } catch {
            print(error)
        }
    }
}

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
    @State private var devicesViewModel: CoreSimulatorDevicesViewModel
    
    init(dirScope: DirectoryScope) {
        _devicesViewModel = .init(
            wrappedValue: .init(
                directory: .coreSimulator,
                dirScope: dirScope
            )
        )
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
    _CoreSimulatorDevicesView(dirScope: .user)
}
