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
        if let devicePlist = device?.devicePlist {
            let mirror = Mirror(reflecting: devicePlist)
            let children = Array(mirror.children)
            List {
                Section {
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

                Section {
                    ForEach(children, id: \.label) { child in
                        if let l = child.label {
                            let label = "\(l)"
                            let value = "\(child.value)"
                            LabeledContent(label, value: value)
                        }
                    }
                }
                
                Section("Access") {
                    if let dateAdded = device?.dateAdded {
                        LabeledContent(
                            "Date Added",
                            value: dateTimeFormatter.localizedString(
                                for: dateAdded,
                                relativeTo: Date()
                            )
                        )
                    }
                    if let lastModified = device?.lastModified {
                        LabeledContent("Last Modified", value: dateTimeFormatter.localizedString(
                            for: lastModified,
                            relativeTo: Date()
                        ))
                    }
                }
                
                Section("Data") {
                    if let device {
                        if device.isLoadingDataContents {
                            ProgressView()
                        } else {
                            if let contents = device.dataContents {
                                ForEach(contents.metadata) { value in
                                    let string = (value.lastModified != nil) ? "\(value.url.lastPathComponent) [\(dateTimeFormatter.localizedString(for: value.lastModified!, relativeTo: .init()))]" : "\(value.url.lastPathComponent)"
                                    LabeledContent(
                                        string,
                                        value: "\(ByteCountFormatter.string(fromByteCount: Int64(value.size), countStyle: .file))"
                                    )
                                }
                                                                
                                let total = contents.metadata.reduce(0) { $0 + $1.size }
                                LabeledContent("Total Data Used", value: ByteCountFormatter.string(fromByteCount: Int64(total), countStyle: .file))
                                    .fontWeight(.heavy)
                                    .font(.title3)
                            } else {
                                ContentUnavailableView {
                                    Text("Failed to load device contents.")
                                }
                            }
                        }
                    } else {
                        ProgressView()
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
