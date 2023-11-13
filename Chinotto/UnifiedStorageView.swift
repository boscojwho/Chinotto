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
    
    init() {
        let viewModels = Directories.allCases.map {
            StorageViewModel(directory: $0)
        }
        _viewModels = .init(wrappedValue: viewModels)
    }
    
    @State private var viewModels: [StorageViewModel]
    
    var body: some View {
        GroupBox {
            VStack {
                HStack {
                    let files = viewModels.reduce(0) { $0 + $1.dirFileCount }
                    Text("All Directories (\(files) files)")
                    Spacer()
                    let storage = viewModels.reduce(0) { $0 + $1.dirSize }
                    Text("\(ByteCountFormatter.string(fromByteCount: Int64(storage), countStyle: .decimal)) of \(ByteCountFormatter.string(fromByteCount: Int64(viewModels.first?.volumeTotalCapacity ?? 0), countStyle: .decimal))")
                    
                    //                Button {
                    //                    reload()
                    //                } label: {
                    //                    if viewModel.isCalculating {
                    //                        ProgressView()
                    //                            .controlSize(.small)
                    //                    } else {
                    //                        Image(systemName: "arrow.clockwise")
                    //                    }
                    //                }
                    //                .disabled(viewModel.isCalculating)
                }
                
                chartView()
                    .contextMenu {
                        Button("Show in Finder") {
                            let url = URL(filePath: Directories.basePath, directoryHint: .isDirectory)
                            NSWorkspace.shared.activateFileViewerSelecting([url])
                        }
                    }
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
            .accessibilityLabel(value.directory.dirName)
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
            Text("Disk Space Used")
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
        .chartLegend(.visible)
        .frame(height: 80)
        .onAppear {
            viewModels.forEach { $0.calculateSize(initial: false, recalculate: false) }
        }
    }
}

#Preview {
    UnifiedStorageView()
}
