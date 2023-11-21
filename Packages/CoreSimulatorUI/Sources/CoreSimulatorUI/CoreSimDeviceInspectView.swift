//
//  CoreSimDeviceInspectView.swift
//
//
//  Created by Bosco Ho on 2023-11-19.
//

import SwiftUI
import CoreSimulatorTools
import FileSystemUI

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
    @State private var selection: Metadata?
    
    public init(device: Binding<CoreSimulatorDevice?>) {
        _device = device
        _viewModel = .init(wrappedValue: .init(device: _device.wrappedValue))
    }
    
    public var body: some View {
        NavigationSplitView {
            if let dataContents = device?.dataContents {
                List(
                    dataContents.metadata,
                    id: \.self,
                    selection: $selection
                ) { value in
                    HStack {
                        VStack {
                            Image(systemName: "folder")
                        }
                        VStack(alignment: .leading) {
                            Text("\(value.key)")
                            Text("\(ByteCountFormatter.string(fromByteCount: Int64(value.size), countStyle: .file))")
                        }
                    }
                }
                .onChange(of: selection) { oldValue, newValue in
                    print("selection changed: \(oldValue?.key ?? "_") -> \(newValue?.key ?? "_")")
                }
            } else {
                ProgressView()
            }
        } detail: {
            NavigationStack {
                if let selection {
                    AnyDirectoryView(dirUrl: selection.url)
                        .id(selection.url.absoluteString)
                } else {
                    GroupBox {
                        Text("Select a directory")
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func makeView() -> some View {
        HSplitView {
            if let dataContents = device?.dataContents {
                GeometryReader { geometry in
                    List(
                        dataContents.metadata,
                        id: \.key,
                        selection: $selection
                    ) { value in
                        //                    Text("\(value.key)")
                        HStack {
                            //                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            //                            .aspectRatio(1, contentMode: .fit)
                            //                            .frame(width: 120)
                            //                            .foregroundStyle(.teal)
                            
                            VStack(alignment: .leading) {
                                Text("\(value.key)")
                                Text("\(ByteCountFormatter.string(fromByteCount: Int64(value.size), countStyle: .file))")
                            }
                        }
                        .background(.teal)
                    }
                    .frame(width: geometry.size.width)
                }
            } else {
                ProgressView()
            }
            
//            List {
//                Section("Directory Name") {
//                    Text("Selected Directory: \(selection?.key ?? "n/a")")
//                }
//            }
//            .frame(minWidth: 360)
        }
    }
}

#Preview {
    CoreSimDeviceInspectView(device: .constant(nil))
}
