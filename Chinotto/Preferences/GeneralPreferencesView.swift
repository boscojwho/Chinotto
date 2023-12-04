//
//  GeneralPreferencesView.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-21.
//

import SwiftUI
import DestructiveActions
import ServiceManagement

struct GeneralPreferencesView: View {
    
    @State private var openAtLogin = false
    @State private var openAtLoginError: Error?
    @AppStorage("showMenuBarExtra") private var showMenuBarExtra = true
    @AppStorage("preferences.general.deletionBehaviour") var deletionBehaviour: DeletionBehaviour = .moveToTrash
    
    @State private var isPresentingResetStorageDataAlert = false
    
    var body: some View {
        Form {
            Section {
                LabeledContent("Menu Bar") {
                    Toggle("Show in Menu Bar (compact view)", isOn: $showMenuBarExtra)
                }
                
                LabeledContent("Open at Login") {
                    Toggle("Launch app on login", isOn: $openAtLogin)
                }
                .onChange(of: openAtLogin) {
                    if openAtLogin {
                        do {
                            try SMAppService.mainApp.register()
                        } catch {
                            openAtLoginError = error
                        }
                    } else {
                        SMAppService.mainApp.unregister { error in
                            openAtLoginError = error
                        }
                    }
                }
                Button("Manage \"Login Items\"...") {
                    SMAppService.openSystemSettingsLoginItems()
                }
            }
            
            Spacer(minLength: 24)
                .frame(height: 24)
            
            Section {
                Picker("Deletion Behavior:", selection: $deletionBehaviour) {
                    ForEach(DeletionBehaviour.allCases) { value in
                        Text(value.description).tag(value)
                    }
                }
                .pickerStyle(.inline)
               
                GroupBox {
                    HStack {
                        Image(systemName: deletionBehaviour.systemImage)
                            .foregroundStyle(deletionBehaviour.accentColor)
                            .fontWeight(.bold)
                        Text(deletionBehaviour.behaviourDescription)
                            .lineLimit(nil)
                    }
                }
                .frame(maxWidth: 320)
            }
            
            Spacer(minLength: 24)
                .frame(height: 24)
            
            Section {
                Button("Reset Storage Data...") {
                    isPresentingResetStorageDataAlert = true
                }
                GroupBox {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                            .fontWeight(.bold)
                        Text("This includes disk usage statistics that may take some time to calculate.")
                    }
                }
                .frame(maxWidth: 320)
            }
        }
        .alert("", isPresented: .init(get: {
            openAtLoginError != nil
        }, set: { _ in
            // no-op
        }), presenting: openAtLoginError, actions: { error in
            Button("Dismiss", role: .cancel) { }
        })
        .alert("Are you sure you want to reset storage data?", isPresented: $isPresentingResetStorageDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                Directories.allCases
                    .map { StorageViewModel(directory: $0).appStorageKeys }
                    .flatMap { $0 }
                    .forEach { UserDefaults.standard.setValue(nil, forKey: $0) }
            }
        }
    }
}

#Preview {
    GeneralPreferencesView()
        .frame(width: 480, height: 600)
}
