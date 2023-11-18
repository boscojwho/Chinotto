//
//  ContentView.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-12.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedXcodeVersion: XcodeVersion = .default
    
    @State private var viewModels: [StorageViewModel]
    @State private var selectedViewModel: StorageViewModel?
    
    @State private var selectedDir: Directories?
    @State private var viewModel: DirectoryViewModel?
    @State private var selectedDetailItem: URL?
    @State private var selectedInspectorItem: URL?
    
    @State private var isPresentingDownloadsPopover: Bool = false
    
    init() {
        let viewModels = Directories.allCases.map {
            StorageViewModel(directory: $0)
        }
        _viewModels = .init(wrappedValue: viewModels)
    }
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedDir) {
                Section {
                    Button("Home", systemImage: "house.fill") {
                        selectedDir = nil
                    }
                    .containerRelativeFrame(.horizontal, alignment: .leading)
                    .controlSize(.large)
                }

                Section("/Developer (User)") {
                    ForEach(Directories.allCases) { value in
                        NavigationLink(value: value) {
                            HStack(spacing: 10) {
                                Group {
                                    Image(systemName: value.systemImage)
                                        .frame(alignment: .leading)
                                }
                                .frame(width: 12, alignment: .leading)
                                Text(value.dirName)
                            }
                        }                    }
                }
                                
                Section("/Developer (System)") {
                    HStack(alignment: .center) {
                        Button("Downloads", systemImage: "square.and.arrow.down.on.square.fill") {
                            let url = URL(filePath: "/Library/Developer/CoreSimulator/Cryptex/Images/Inbox", directoryHint: .isDirectory)
                            NSWorkspace.shared.activateFileViewerSelecting([url])
                        }
                        .controlSize(.large)
                        
                        Button("", systemImage: "questionmark.circle") {
                            isPresentingDownloadsPopover = true
                        }
                        .buttonStyle(.plain)
                        .controlSize(.large)
                        .popover(isPresented: $isPresentingDownloadsPopover) {
                            downloadsPopover()
                        }
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 200, ideal: 240)
        } detail: {
            if let selectedDir {
                makeSelectedDirectoryView(selectedDir)
                    .navigationSplitViewColumnWidth(min: 600, ideal: 720)
            } else {
                DirectoriesStorageView(viewModels: $viewModels)
                    .navigationTitle("Chinotto")
                    .navigationSplitViewColumnWidth(min: 600, ideal: 720)
            }
        }
        .navigationSplitViewStyle(.balanced)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Picker("Xcode", selection: $selectedXcodeVersion) {
                    ForEach(XcodeVersion.allCases) { value in
                        Text(value.description)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func downloadsPopover() -> some View {
        ScrollView {
            VStack {
                HStack(spacing: 0) {
                    Text("Downloads")
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    Spacer()
                }
                HStack(spacing: 0) {
                    Text("This is where simulator images are stored when downloaded via Xcode.")
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    Spacer()
                }
                Divider()
                
                HStack {
                    Image(systemName: "lightbulb.max")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24)
                        .symbolEffect(
                            .variableColor.iterative,
                            options: .repeat(4),
                            isActive: isPresentingDownloadsPopover
                        )
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color.yellow, Color.blue)
                    Text("Tip")
                        .fontWeight(.black)
                        .foregroundStyle(.primary)
                    Spacer()
                }
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                
                HStack(spacing: 0) {
                    Text("If download finishes, but Xcode is unable to install a simulator runtime (e.g. due to insufficient storage), you may wish to manually install the simulator, instead.\n\nUsing Xcode's built-in reload button in the Download panel causes it to re-download the entire file, which is time-consuming.")
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .foregroundStyle(.primary)
                }
            }
            .frame(width: 240)
            .padding(10)
        }
    }
    
    @ViewBuilder
    private func makeSelectedDirectoryView(_ directory: Directories) -> some View {
        switch directory {
        case .coreSimulator:
            CoreSimulatorView(directoryScope: .user)
        case .developerDiskImages:
            DeveloperDiskImagesView()
        case .toolchains:
            ToolchainsView()
        case .xcode:
            XcodeView()
        case .xcPGDevices:
            XCPGDevicesView()
        case .xcTestDevices:
            XCTestDevicesView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
