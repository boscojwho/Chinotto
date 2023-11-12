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
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(Directories.allCases) { value in
                    Button(value.dirName, systemImage: value.systemImage) {
                        selectedDir = value
                    }
                    .containerRelativeFrame(.horizontal)
                }
                .onDelete(perform: deleteItems)
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
            .onChange(of: viewModel?.directory, { oldValue, newValue in
                if let viewModel {
                    viewModel.reloadContents()
                    viewModel.calculateDirectorySize()
                }
            })
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
                .task(priority: .userInitiated) {
                    viewModel.calculateDirectorySize()
                }
            } else {
                Text("Select an item")
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
