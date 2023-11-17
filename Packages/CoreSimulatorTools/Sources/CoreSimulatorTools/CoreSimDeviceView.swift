//
//  CoreSimDeviceView.swift
//
//
//  Created by Bosco Ho on 2023-11-15.
//

import SwiftUI

public struct CoreSimDeviceView: View {
    
    @Binding var device: CoreSimulatorDevice?
    
    @State private var isPresentingDeleteDeviceAlert = false
    
    private let dateTimeFormatter = RelativeDateTimeFormatter()
    
    public init(device: Binding<CoreSimulatorDevice?>) {
        _device = device
        device.wrappedValue?.loadDataContents()
    }
    
    public var body: some View {
        if let device, let devicePlist = device.devicePlist {
            let mirror = Mirror(reflecting: devicePlist)
            let children = Array(mirror.children)
            List {
                Section {
                    GroupBox {
                        HStack {
                            Text("\(devicePlist.name)")
                                .font(.title2)
                            Spacer()
                            Button("Delete Device...") {
                                isPresentingDeleteDeviceAlert = true
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                        }
                    }
                }

                Section("Metadata") {
                    ForEach(children, id: \.label) { child in
                        if let l = child.label {
                            let label = "\(l)"
                            let value = "\(child.value)"
                            LabeledContent(label, value: value)
                        }
                    }
                }
                
                Section("Access") {
                    if let dateAdded = device.dateAdded {
                        LabeledContent(
                            "Date Added",
                            value: dateTimeFormatter.localizedString(
                                for: dateAdded,
                                relativeTo: Date()
                            )
                        )
                    }
                    if let lastModified = device.lastModified {
                        LabeledContent("Last Modified", value: dateTimeFormatter.localizedString(
                            for: lastModified,
                            relativeTo: Date()
                        ))
                    }
                }
                
                Section("Data") {
                    if device.isLoadingDataContents {
                        ProgressView()
                    } else {
                        GroupBox {
                            if let contents = device.dataContents {
                                Table(contents.metadata) {
                                    TableColumn("Directory") { value in
                                        Text("\(value.url.lastPathComponent)")
                                    }
                                    
                                    TableColumn("Last Modified") { value in
                                        if let date = value.lastModified {
                                            Text("\(dateTimeFormatter.localizedString(for: date, relativeTo: Date()))")
                                        } else {
                                            Text("Never")
                                        }
                                    }
                                    
                                    TableColumn("Size") { value in
                                        HStack {
                                            Spacer()
                                            Text("\(ByteCountFormatter.string(fromByteCount: Int64(value.size), countStyle: .file))")
                                                .fontWeight(.medium)
                                        }
                                    }
                                }
                                .frame(height: 280)
                                
                                GroupBox {
                                    let total = contents.metadata.reduce(0) { $0 + $1.size }
                                    LabeledContent("Total Data Used", value: ByteCountFormatter.string(fromByteCount: Int64(total), countStyle: .file))
                                        .fontWeight(.heavy)
                                        .font(.title3)
                                        .padding(.horizontal, 4)
                                }
                            } else {
                                ContentUnavailableView {
                                    Text("Failed to load device contents.")
                                }
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        NSWorkspace.shared.activateFileViewerSelecting([device.root])
                    } label: {
                        Text("Show in Finder")
                    }
                }
            }
            .alert("Are you sure you wish to permanently delete\n\"\(devicePlist.name)\"?", isPresented: $isPresentingDeleteDeviceAlert) {
                Button("Cancel", role: .cancel) {
                    
                }
                Button("Delete", role: .destructive) {
                    
                }
            } message: {
                Text("This operation cannot be reversed.\n\nYou may wish to backup test data associated with this device before proceeding.")
            }

        } else {
            ProgressView()
        }
    }
}

#Preview {
    CoreSimDeviceView(device: .constant(nil))
}
