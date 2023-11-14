//
//  ContentView.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-12.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    @State private var selectedDir: Directories?
    @State private var viewModel: DirectoryViewModel?
    @State private var selectedDetailItem: URL?
    @State private var selectedInspectorItem: URL?
    
    @State private var isPresentingDownloadsPopover: Bool = false
    
    var body: some View {
        NavigationSplitView {
            List {
                Section {
                    Button("Home", systemImage: "house.fill") {
                        viewModel = nil
                    }
                    .containerRelativeFrame(.horizontal, alignment: .leading)
                }
                
                Divider()
                
                Section {
                    ForEach(Directories.allCases) { value in
                        Button(value.dirName, systemImage: value.systemImage) {
                            selectedDir = value
                        }
                        .containerRelativeFrame(.horizontal, alignment: .leading)
                    }
                    .onDelete(perform: deleteItems)
                }
                
                Divider()
                
                Section {
                    HStack(alignment: .center) {
                        Button("Downloads", systemImage: "square.and.arrow.down.on.square.fill") {
                            let url = URL(filePath: "/Library/Developer/CoreSimulator/Cryptex/Images/Inbox", directoryHint: .isDirectory)
                            NSWorkspace.shared.activateFileViewerSelecting([url])
                        }
                        
                        Button("", systemImage: "questionmark.circle") {
                            isPresentingDownloadsPopover = true
                        }
                        .buttonStyle(.plain)
                        .controlSize(.regular)
                        .popover(isPresented: $isPresentingDownloadsPopover) {
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
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .toolbar {
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .onChange(of: selectedDir, { oldValue, newValue in
                if let newValue {
                    viewModel = .init(directory: .init(directory: newValue))
                }
            })
//            .onChange(of: viewModel?.directory, { oldValue, newValue in
//                if let viewModel {
//                    viewModel.reloadContents()
//                    Task {
//                        await viewModel.calculateDirectorySize()
//                    }
//                }
//            })
        } content: {
            if let viewModel {
                List(selection: $selectedDetailItem) {
                    Section("Size: \(viewModel.byteSize())") {
                        ForEach(viewModel.contents, id: \.hashValue) { value in
                            NavigationLink(value: value) {
                                Text(value.absoluteString)
                            }
                        }
                        .navigationTitle(viewModel.directory.url.lastPathComponent)
                    }
                }
//                .task(priority: .userInitiated) {
//                    viewModel.calculateDirectorySize()
//                }
            } else {
               DirectoriesStorageView()
                    .navigationTitle("Chinotto")
            }
        } detail: {
            if let selectedDetailItem {
                Button(action: {
                    selectedInspectorItem = selectedDetailItem
                }, label: {
                    Text(selectedDetailItem.absoluteString)
                })
            }
        }
        .inspector(
            isPresented: .init(
                get: {
                    selectedInspectorItem != nil
                },
                set: { newValue in
                    if newValue == false {
                        selectedInspectorItem = nil
                    }
                })
        ) {
            Text("Inspector View")
            if let selectedDetailItem {
                Text("\(selectedDetailItem.absoluteString)")
            }
        }
    }

    private func addItem() {
//        withAnimation {
//            let newItem = Item(timestamp: Date())
//            modelContext.insert(newItem)
//        }
    }

    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            for index in offsets {
//                modelContext.delete(items[index])
//            }
//        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
