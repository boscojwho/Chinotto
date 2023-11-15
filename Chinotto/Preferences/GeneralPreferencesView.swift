//
//  GeneralPreferencesView.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-14.
//

import SwiftUI
import SwiftData

extension ModelContainer {
    
    // URLs to SwiftData default store files.
    static var defaultStoreUrls: [URL] {
        guard let dirUrl = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last else { return [] }
        let store = dirUrl.appendingPathComponent("default.store")
        let storeShm = dirUrl.appendingPathComponent("default.store-shm")
        let storeWal = dirUrl.appendingPathComponent("default.store-wal")
        return [store, storeShm, storeWal]
    }
}

struct GeneralPreferencesView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var swiftDataStoreSize: Int?
    @State private var resetAppDataAlert = false
    
    var body: some View {
        Form {
            Section("Storage") {
                if let swiftDataStoreSize {
                    LabeledContent("SwiftData Store") {
                        Text(ByteCountFormatter.string(fromByteCount: Int64(swiftDataStoreSize), countStyle: .file))
                    }
                } else {
                    LabeledContent("SwiftData Store") {
                        ProgressView()
                    }
                }
                
                Button {
                    resetAppDataAlert = true
                } label: {
                    Text("Reset app data...")
                }
            }
            .onAppear {
                let size = ModelContainer.defaultStoreUrls.reduce(0) {
                    do {
                        let fileSizeResourceValue = try $1.resourceValues(forKeys: [.fileSizeKey])
                        let fileSize = fileSizeResourceValue.fileSize ?? 0
                        print("Size of file: \(fileSize) bytes")
                        return $0 + fileSize
                    } catch {
                        return $0
                    }
                }
                print("swiftdata store size -> \(ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file))")
                swiftDataStoreSize = size
            }
        }
        .frame(idealWidth: 480, idealHeight: 320)
        .alert("Reset App Data", isPresented: $resetAppDataAlert, presenting: "") { _ in
            Button(role: .destructive) {
                resetAppData()
            } label: {
                Text("Reset")
            }
            Button(role: .cancel) {
                resetAppDataAlert = false
            } label: {
                Text("Cancel")
            }

        } message: { _ in
            Text("Are you sure?")
        }
    }
    
    private func resetAppData() {
        modelContext.container.deleteAllData()
        
        do {
            try modelContext.delete(model: SizeMetadata.self)
        } catch {
            print(error)
        }
        
        Directories.allCases
            .map { StorageViewModel(directory: $0).appStorageKeys }
            .flatMap { $0 }
            .forEach { UserDefaults.standard.setValue(nil, forKey: $0) }
    }
}

#Preview {
    GeneralPreferencesView()
}
