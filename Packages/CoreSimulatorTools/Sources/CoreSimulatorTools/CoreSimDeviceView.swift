//
//  CoreSimDeviceView.swift
//
//
//  Created by Bosco Ho on 2023-11-15.
//

import SwiftUI

public struct CoreSimDeviceView: View {
    
    @Binding var device: CoreSimulatorDevice?
    
    public init(device: Binding<CoreSimulatorDevice?>) {
        _device = device
        Task {
            device.wrappedValue?.loadDataContents()
        }
    }
    
    public var body: some View {
        if let devicePlist = device?.devicePlist {
            let mirror = Mirror(reflecting: devicePlist)
            let children = Array(mirror.children)
            List {
                Text("\(devicePlist.name)")
                    .font(.title3)
                
                Section {
                    ForEach(children, id: \.label) { child in
                        if let l = child.label {
                            let label = "\(l)"
                            let value = "\(child.value)"
                            LabeledContent(label, value: value)
                        }
                    }
                }
                
                Section("Data") {
                    if let device {
                        if device.isLoadingDataContents {
                            ProgressView()
                        } else {
                            if let contents = device.dataContents {
                                ForEach(contents.metadata) { value in
                                    LabeledContent(value.url.lastPathComponent, value: "\(ByteCountFormatter.string(fromByteCount: Int64(value.size), countStyle: .file))")
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
        } else {
            ProgressView()
        }
    }
}

#Preview {
    CoreSimDeviceView(device: .constant(nil))
}
