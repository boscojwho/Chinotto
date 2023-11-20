//
//  CoreSimDeviceInspectView.swift
//
//
//  Created by Bosco Ho on 2023-11-19.
//

import SwiftUI
import CoreSimulatorTools

@Observable
public final class CoreSimDeviceInspectViewModel {
    public var device: CoreSimulatorDevice?
    
    public init(device: CoreSimulatorDevice? = nil) {
        self.device = device
    }
}

public struct CoreSimDeviceInspectView: View {
    
    @Binding var device: CoreSimulatorDevice?
    
    @State private var viewModel: CoreSimDeviceInspectViewModel
    
    public init(device: Binding<CoreSimulatorDevice?>) {
        _device = device
        _viewModel = .init(wrappedValue: .init(device: _device.wrappedValue))
    }
    
    public var body: some View {
        HSplitView {
            List {
                Section("Directories") {
                    if let dataContents = device?.dataContents {
                        ForEach(dataContents.metadata) { value in
                            Text("\(value.key): \(ByteCountFormatter.string(fromByteCount: Int64(value.size), countStyle: .file))")
                        }
                    } else {
                        ProgressView()
                    }
                }
            }
        }
    }
}

#Preview {
    CoreSimDeviceInspectView(device: .constant(nil))
}
