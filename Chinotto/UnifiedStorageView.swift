//
//  UnifiedStorageView.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-13.
//

import SwiftUI
import Charts

/// Shows storage consumed for all directories in a unified view.
struct UnifiedStorageView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Binding var viewModels: [StorageViewModel]
    @State private var isReloading = false
    
    private var sizeClass: UserInterfaceSizeClass {
        horizontalSizeClass ?? .regular
    }
    
    var body: some View {
        GroupBox {
            VStack {
                HStack {
                    Text("All Directories")
                    Spacer()
                    let storage = viewModels.reduce(0) { $0 + $1.dirSize }
                    Text("\(ByteCountFormatter.string(fromByteCount: Int64(storage), countStyle: .decimal)) of \(ByteCountFormatter.string(fromByteCount: Int64(viewModels.first?.volumeTotalCapacity ?? 0), countStyle: .decimal))")
                    
                    Button {
                        reload()
                    } label: {
                        HStack {
                            if isReloading {
                                Text("Calculating...")
                                ProgressView()
                                    .controlSize(.small)
                            } else {
                                Text("Calculate")
                                Image(systemName: "arrow.clockwise")
                            }
                        }
                    }
                    .disabled(isReloading)
                }
                
                chartView()
                    .contextMenu {
                        Button("Show in Finder") {
                            let url = URL(filePath: Directories.userBasePath, directoryHint: .isDirectory)
                            NSWorkspace.shared.activateFileViewerSelecting([url])
                        }
                    }
            }
        }
    }
    
    private func reload() {
        isReloading = true
        viewModels.forEach { $0.beginCalculating() }

        Task {
            await withTaskGroup(of: Void.self, returning: Void.self) { taskGroup in
                viewModels.forEach { viewModel in
                    taskGroup.addTask(priority: .userInitiated) {
                        await viewModel.calculateSize(initial: false, recalculate: true)
                    }
                }
            }
            Task { @MainActor in
                viewModels.forEach { $0.endCalculating() }
                isReloading = false
            }
        }
    }
    
    @ViewBuilder
    private func chartView() -> some View {
        Chart(viewModels) { value in
            Plot {
                BarMark(
                    x: .value("Directory Size", value.dirSize)
                )
//                .foregroundStyle(value.directory.accentColor)
                .foregroundStyle(by: .value("Data Category", value.directory.dirName))
            }
            /// This causes crash on scroll, why? [2023.11]
//            .accessibilityLabel(value.directory.dirName)
        }
        .chartForegroundStyleScale(
            domain: Directories.allCases,
            range: Directories.allCases.compactMap { $0.accentColor }
        )
        .chartXScale(domain: [0, viewModels.first?.volumeTotalCapacity ?? 0])
        .chartXAxis {
            AxisMarks(
                format: .byteCount(style: .memory, allowedUnits: .all, spellsOutZero: true, includesActualByteCount: false),
                values: viewModels.first?.axisValues ?? []
            )
        }
        .chartXAxisLabel(position: .top) {
            switch sizeClass {
            case .compact:
                EmptyView()
            case .regular:
                Text("Disk Space Used")
            @unknown default:
                Text("Disk Space Used")
            }
        }
        .chartPlotStyle { plotArea in
            plotArea
#if os(macOS)
                .background(Color.gray.opacity(0.2))
#else
                .background(Color(.systemFill))
#endif
                .cornerRadius(8)
        }
        .chartLegend(chartLegendVisibility)
        .frame(height: sizeClass == .compact ? 40 : 80)
    }
    
    private var chartLegendVisibility: Visibility {
        switch sizeClass {
        case .compact:
                .hidden
        case .regular:
                .visible
        @unknown default:
                .visible
        }
    }
}

#Preview {
    UnifiedStorageView(viewModels: .constant([.init(directory: .developerDiskImages)]))
}
