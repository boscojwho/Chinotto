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
            }
        } else {
            ProgressView()
        }
    }
}

#Preview {
    CoreSimDeviceView(device: .constant(nil))
}
