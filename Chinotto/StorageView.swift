//
//  StorageView.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-12.
//

import SwiftUI
import Charts

@Observable
final class StorageViewModel: Identifiable {
    
    let directory: Directories
    init(directory: Directories) {
        self.directory = directory
        self.volumeTotalCapacity = URL(filePath: directory.path, directoryHint: .isDirectory).volumeTotalCapacity()
    }
    
    /// timeIntervalSinceReferenceDate
    var lastUpdated: TimeInterval {
        get {
            access(keyPath: \.lastUpdated)
            return UserDefaults.standard.double(forKey: "\(directory.dirName).dirSize.lastUpdated.appStorage.key")
        }
        set {
            withMutation(keyPath: \.lastUpdated) {
                UserDefaults.standard.setValue(newValue, forKey: "\(directory.dirName).dirSize.lastUpdated.appStorage.key")
            }
        }
    }
    
    @ObservationIgnored
    private var performedInitialLoad = false
    var isCalculating = false
    
    var volumeTotalCapacity: Int?
    var dirFileCount: Int {
        get {
            access(keyPath: \.dirFileCount)
            return UserDefaults.standard.integer(forKey: "\(directory.dirName).dirFileCount.appStorage.key")
        }
        set {
            withMutation(keyPath: \.dirFileCount) {
                UserDefaults.standard.setValue(newValue, forKey: "\(directory.dirName).dirFileCount.appStorage.key")
            }
        }
    }
    var dirSize: Int {
        get {
            access(keyPath: \.dirSize)
            return UserDefaults.standard.integer(forKey: "\(directory.dirName).dirSize.appStorage.key")
        }
        set {
            withMutation(keyPath: \.dirSize) {
                UserDefaults.standard.setValue(newValue, forKey: "\(directory.dirName).dirSize.appStorage.key")
            }
        }
    }
    
    var axisValues: [Int64] {
        let maxValue = volumeTotalCapacity ?? dirSize
        let values = [
            Int64(0),
            Int64(((maxValue/2)/2)),
            Int64((maxValue/2)),
            Int64((Double(maxValue/2)*1.5)),
            Int64(maxValue)
        ]
        return values
    }

    /// - Parameter initial: If `true`, only calculates size if not yet calculated.
    func calculateSize(initial: Bool, recalculate: Bool) {
        defer { performedInitialLoad = true }
        
        if initial, performedInitialLoad == true {
            return
        }
        
        if !recalculate, dirSize != 0 {
            return
        }
        
        // TODO: Pre-calculating dir count doesn't yield faster performance. See if there's a faster way to calculate file count.
        isCalculating = true
        let count = URL.directoryContentsCount(url: .init(filePath: directory.path, directoryHint: .isDirectory))
        self.dirFileCount = count
        let size = URL.directorySize(url: .init(filePath: directory.path, directoryHint: .isDirectory))
        self.dirSize = size
        isCalculating = false
        lastUpdated = Date().timeIntervalSinceReferenceDate
    }
    
    private let byteCountFormatter = ByteCountFormatter()
    var dirSizeFormattedString: String {
        byteCountFormatter
            .string(fromByteCount: Int64(dirSize))
    }
    var volumeTotalCapacityFormattedString: String {
        byteCountFormatter
            .string(fromByteCount: Int64(volumeTotalCapacity ?? 0))
    }
}

struct StorageView: View {
    
    init(directory: Directories) {
        _viewModel = .init(wrappedValue: .init(directory: directory))
    }
    
    @State private var viewModel: StorageViewModel
    
    var body: some View {
        Group {
            HStack {
                Spacer()
                Text("Last Updated: \(Date(timeIntervalSinceReferenceDate: viewModel.lastUpdated), style: .relative)")
                    .font(.headline)
                    .fontWeight(.regular)
                    .foregroundStyle(.secondary)
            }
            .offset(y: 8)
            GroupBox {
                VStack {
                    HStack {
                        Text("\(viewModel.directory.dirName) (\(viewModel.dirFileCount) files)")
                        Spacer()
                        Text("\(viewModel.dirSizeFormattedString) of \(viewModel.volumeTotalCapacityFormattedString)")
                        
                        Button {
                            reload()
                        } label: {
                            if viewModel.isCalculating {
                                ProgressView()
                                    .controlSize(.small)
                            } else {
                                Image(systemName: "arrow.clockwise")
                            }
                        }
                        .disabled(viewModel.isCalculating)
                    }
                    
                    chartView()
                }
            }
        }
    }
    
    private func reload() {
        Task(priority: .background) {
            viewModel.calculateSize(initial: false, recalculate: true)
        }
    }
    
    @ViewBuilder
    private func chartView() -> some View {
        Chart {
            Plot {
                BarMark(
                    x: .value("Directory Size", viewModel.dirSize)
                )
                .foregroundStyle(viewModel.directory.accentColor)
                /// Use by(.value) to automatically vary foreground style (colour) based on data.
//                .foregroundStyle(by: .value("Data Category", viewModel.directory.dirName))
                //                .annotation(position: .overlay) {
                //                    Text("\(viewModel.annotationText)")
                //                        .fontWeight(.bold)
                //                        .background(.regularMaterial)
                //                }
            }
            .accessibilityLabel(viewModel.directory.dirName)
            .accessibilityValue("\(viewModel.dirSize, specifier: "%.1f") GB")
        }
        .chartPlotStyle { plotArea in
            plotArea
#if os(macOS)
                .background(viewModel.directory.accentColor.opacity(0.2))
//                .background(Color.gray.opacity(0.2))
#else
                .background(viewModel.directory.accentColor.opacity(0.2))
//                .background(Color(.systemFill))
#endif
                .cornerRadius(8)
        }
        //        .accessibilityChartDescriptor(self)
        //        .chartXAxis(.hidden)
        //        .chartXScale(domain: 0...128)
        .chartXAxis {
            AxisMarks(
                format: .byteCount(style: .memory, allowedUnits: .all, spellsOutZero: true, includesActualByteCount: false),
                values: viewModel.axisValues
            )
        }
        .chartXScale(domain: [0, viewModel.volumeTotalCapacity ?? viewModel.dirSize])
        .chartXAxisLabel(position: .top) {
            Text("Disk Space Used")
        }
        .chartYAxis(.hidden)
//        .chartYScale(range: .plotDimension(endPadding: -8))
//        .chartLegend(position: .top, spacing: 8)
        .chartLegend(.hidden)
        .frame(height: 64)
        .onAppear {
            viewModel.calculateSize(initial: true, recalculate: false)
        }
    }
}

#Preview {
    StorageView(directory: .developerDiskImages)
}
