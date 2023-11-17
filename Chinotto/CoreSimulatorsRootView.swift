//
//  CoreSimulatorsRootView.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-16.
//

import SwiftUI

struct CoreSimulatorsRootView: View {
    
    @State private var storageViewModel: StorageViewModel = .init(directory: .coreSimulator)
    
    var body: some View {
        @Bindable var vm = storageViewModel
        _CoreSimulatorDevicesView(
            dirScope: .user,
            storageViewModel: $vm
        )
    }
}

#Preview {
    CoreSimulatorsRootView()
}
