//
//  _CoreSimulatorDevicesView.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-15.
//

import SwiftUI
import Charts
import CoreSimulatorTools
import CoreSimulatorUI
import DestructiveActions

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

    @AppStorage("coreSimDevices.loadAllDevices.lastUpdated.appStorage.key") var lastUpdatedAllDevices: TimeInterval = Date.distantPast.timeIntervalSinceReferenceDate
    @AppStorage("preferences.general.deletionBehaviour") var deletionBehaviour: DeletionBehaviour = .moveToTrash

    @Environment(\.openWindow) var openWindow
    
    @Bindable var storageViewModel: StorageViewModel
    @State private var devicesViewModel: CoreSimulatorDevicesViewModel
    
    @State private var selectedDevices: Set<CoreSimulatorDevice.ID> = .init()
    @State private var tableSortOrder = [KeyPathComparator(\CoreSimulatorDevice.totalSize)]
    
    @State private var isPresentingInspectorViewForDevice = true
    @State private var deviceForInspectorView: CoreSimulatorDevice? = nil
    
    @State private var isPresentingDeleteDeviceAlert = false
    
    @State private var isPresentingDeleteErrorAlert = false
    @State private var deleteError: DestructiveActionError?
    
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
    
    private var isCalculating: Bool {
        devicesViewModel.devices.first { $0.dataContents != nil } != nil
    }
    
    private var isSelectingMultipleDevices: Bool {
        selectedDevices.count > 1
    }
    
    private var selectedDevicesSize: Int {
        devicesViewModel.devices
            .filter { devices in
                selectedDevices.contains { selected in selected == devices.id }
            }
            .reduce(0) { $0 + $1.totalSize }
    }
    
    private func selectedCoreSimDevices() -> [CoreSimulatorDevice] {
        devicesViewModel.devices
            .filter { devices in
                selectedDevices.contains { selected in selected == devices.id }
            }
    }
    
    var body: some View {
        Group {
            tableView()
                .padding(.top, 80 + 64)
                .overlay(alignment: .top) {
                    VStack {
                        GroupBox {
                            storageChartView()
                        }
                        
                        GroupBox {
                            HStack {
                                Spacer()
                                Text("\(ByteCountFormatter.string(fromByteCount: Int64(selectedDevicesSize), countStyle: .file))")
                                Button("Delete selected (\(selectedDevices.count))...", role: .destructive) {
                                    isPresentingDeleteDeviceAlert = true
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.red)
                                .disabled(selectedDevices.isEmpty)
                            }
                            .frame(height: 36)
                            .padding(.horizontal, 12)
                        }
                    }
                    .padding(8)
                }
                .task {
                    devicesViewModel.loadDevices()
                }
                .onChange(of: isCalculating) { oldValue, newValue in
                    if newValue == false {
                        lastUpdatedAllDevices = Date().timeIntervalSinceReferenceDate
                    }
                }
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                GroupBox {
                    if lastUpdatedAllDevices == Date.distantPast.timeIntervalSinceReferenceDate {
                        Text("Last Updated: Never")
                    } else {
                        let date = Date(timeIntervalSinceReferenceDate: lastUpdatedAllDevices)
                        Text("Last Updated: \(dateTimeFormatter.localizedString(for: date, relativeTo: Date()))")
                    }
                }
                Button {
                    
                } label: {
                    HStack {
                        if isCalculating {
                            Text("Calculating...")
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Text("Calculate")
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
                .disabled(isCalculating)
            }
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
        .alert("Are you sure you wish to permanently delete\n\"^[\(selectedDevices.count) device](inflect: true)\"?", isPresented: $isPresentingDeleteDeviceAlert) {
            Button("Cancel", role: .cancel) {
                
            }
            Button("Delete", role: .destructive) {
                defer { selectedDevices.removeAll() }
                let devices = selectedCoreSimDevices()
                devices.forEach { device in
                    do {
                        try FileManager.default.delete(coreSimDevice: device, moveToTrash: deletionBehaviour == .moveToTrash)
                        if let index = devicesViewModel.devices.firstIndex(where: { $0.id == device.id }) {
                            devicesViewModel.devices.remove(at: index)
                        }
                    } catch {
                        if let error = error as? DestructiveActionError {
                            isPresentingDeleteErrorAlert = true
                            deleteError = error
                        }
                    }
                }
            }
        } message: {
            Text("This operation cannot be reversed.\n\nYou may wish to backup test data associated with this device before proceeding.")
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
            if items.isEmpty {
                Button("Show in Finder", action: {})
                    .disabled(true)
            } else {
                Button {
                    let devicesToShow = devicesViewModel.devices.filter { devices in
                        items.contains { selected in selected == devices.id }
                    }
                    let fileUrls = devicesToShow.compactMap { $0.root }
                    NSWorkspace.shared.activateFileViewerSelecting(fileUrls)
                } label: {
                    let text = items.count > 1 ? "Show in Finder (\(items.count))" : "Show in Finder"
                    Text(text)
                }
            }
        } primaryAction: { deviceIds in
            for id in deviceIds {
                if let device = devicesViewModel.devices.first(where: { $0.id == id }) {
                    isPresentingInspectorViewForDevice = true
                    deviceForInspectorView = device
//                    openWindow(id: "CoreSimulatorDevice", value: device)
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
    
    @ViewBuilder
    private func storageChartView() -> some View {
        let sizeForAllDevices = devicesViewModel.devices.reduce(0) { $0 + $1.totalSize }
        let volumeTotalCapacity = devicesViewModel.devices.first?.root.volumeTotalCapacity() ?? 0
        let maxValue = volumeTotalCapacity
        let xAxisValues = [
            Int64(0),
            Int64(((maxValue/2)/2)),
            Int64((maxValue/2)),
            Int64((Double(maxValue/2)*1.5)),
            Int64(maxValue)
        ]
        Chart {
            Plot {
                BarMark(x: .value("Size", sizeForAllDevices))
                    .cornerRadius(6, style: .continuous)
                    .annotation(position: .overlay) {
                        GroupBox {
                            Text("\(ByteCountFormatter.string(fromByteCount: Int64(sizeForAllDevices), countStyle: .file))")
                        }
                    }
            }
        }
        .chartXAxisLabel(position: .top) {
            let count = devicesViewModel.devices.filter { $0.dataContents == nil }.count
            if count > 0 {
                Text("Disk Space Used - Calculating \(count) ^[of \(devicesViewModel.devices.count) device](inflect: true)")
            } else {
                Text("Disk Space Used - ^[Showing \(devicesViewModel.devices.count) device](inflect: true)")
            }
        }
        .chartXAxis {
            AxisMarks(
                format: .byteCount(style: .memory, allowedUnits: .all, spellsOutZero: true, includesActualByteCount: false),
                values: xAxisValues
            )
        }
        .chartXScale(domain: [0, volumeTotalCapacity])
        .chartYAxis(.hidden)
        .chartLegend(.hidden)
        .frame(height: 64)
    }
}

#Preview {
    _CoreSimulatorDevicesView(
        dirScope: .user,
        storageViewModel: .init(.init(directory: .developerDiskImages))
    )
}
