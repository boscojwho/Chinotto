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
    
    private enum AppStorageKeys: CaseIterable {
        case lastUpdated
        case dirFileCount, dirSize
        
        func key(_ directory: Directories) -> String {
            switch self {
            case .lastUpdated:
                "\(directory.dirName).dirSize.lastUpdated.appStorage.key"
            case .dirFileCount:
                "\(directory.dirName).dirFileCount.appStorage.key"
            case .dirSize:
                "\(directory.dirName).dirSize.appStorage.key"
            }
        }
    }
    
    var appStorageKeys: [String] {
        AppStorageKeys.allCases.map { $0.key(directory) }
    }
    
    /// timeIntervalSinceReferenceDate
    var lastUpdated: TimeInterval {
        get {
            access(keyPath: \.lastUpdated)
            let value = UserDefaults.standard.double(forKey: AppStorageKeys.lastUpdated.key(directory))
            return value == 0 ? Date.distantPast.timeIntervalSinceReferenceDate : value
        }
        set {
            withMutation(keyPath: \.lastUpdated) {
                UserDefaults.standard.setValue(newValue, forKey: AppStorageKeys.lastUpdated.key(directory))
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
            return UserDefaults.standard.integer(forKey: AppStorageKeys.dirFileCount.key(directory))
        }
        set {
            withMutation(keyPath: \.dirFileCount) {
                UserDefaults.standard.setValue(newValue, forKey: AppStorageKeys.dirFileCount.key(directory))
            }
        }
    }
    var dirSize: Int {
        get {
            access(keyPath: \.dirSize)
            return UserDefaults.standard.integer(forKey: AppStorageKeys.dirSize.key(directory))
        }
        set {
            withMutation(keyPath: \.dirSize) {
                UserDefaults.standard.setValue(newValue, forKey: AppStorageKeys.dirSize.key(directory))
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

    func beginCalculating() {
        isCalculating = true
    }
    
    func endCalculating() {
        isCalculating = false
    }
    
    private(set) var dirMetadata: [URL: Int] = [:]
    private(set) var fileMetadata: [URL: Int] = [:]
    private(set) var dirSizeMetadata: [SizeMetadata] = []
    private(set) var fileSizeMetadata: [SizeMetadata] = []
    
    /// - Parameter initial: If `true`, only calculates size if not yet calculated.
    func calculateSize(initial: Bool, recalculate: Bool, shallowMetadata: Bool = false) {
        defer { performedInitialLoad = true }
        
        if initial, performedInitialLoad == true {
            return
        }
        
        if !recalculate, dirSize != 0 {
            return
        }
        
        isCalculating = true
        
        #if CALCULATE_STORAGE_METADATA
        let count = URL.directoryContentsCount(url: .init(filePath: directory.path, directoryHint: .isDirectory))
        self.dirFileCount = count
        var dirMetadata: [URL: Int] = [:]
        var fileMetadata: [URL: Int] = [:]
        let size = URL.directorySize(url: .init(filePath: directory.path, directoryHint: .isDirectory), dirMetadata: &dirMetadata, fileMetadata: &fileMetadata)
        self.dirMetadata = dirMetadata
        self.fileMetadata = fileMetadata
        self.dirSizeMetadata = dirMetadata
            .sorted(by: { lhs, rhs in lhs.value > rhs.value })
            .map {
                SizeMetadata(
                    key: $0.key,
                    value: ByteCountFormatter.string(
                        fromByteCount: Int64($0.value),
                        countStyle: .file
                    )
                )
            }
        self.fileSizeMetadata = fileMetadata
            .sorted(by: { lhs, rhs in lhs.value > rhs.value })
            .map {
                SizeMetadata(
                    key: $0.key,
                    value: ByteCountFormatter.string(
                        fromByteCount: Int64($0.value),
                        countStyle: .file
                    )
                )
            }
        #else
        self.dirSize = URL.directorySize(
            url: .init(filePath: directory.path, directoryHint: .isDirectory)
        )
        #endif
        
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
    
    @Bindable var viewModel: StorageViewModel
    
    var body: some View {
        Group {
            HStack {
                Spacer()
                if Date(timeIntervalSinceReferenceDate: viewModel.lastUpdated) == .distantPast {
                    Text("Last Updated: Never")
                        .font(.headline)
                        .fontWeight(.regular)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Last Updated: \(Date(timeIntervalSinceReferenceDate: viewModel.lastUpdated), style: .relative)")
                        .font(.headline)
                        .fontWeight(.regular)
                        .foregroundStyle(.secondary)
                }
            }
//            .offset(y: 8)
            GroupBox {
                VStack {
                    HStack {
                        Text("\(viewModel.directory.dirName)")
                        Spacer()
                        Text("\(viewModel.dirSizeFormattedString) of \(viewModel.volumeTotalCapacityFormattedString)")
                        
                        Button {
                            reload()
                        } label: {
                            HStack {
                                if viewModel.isCalculating {
                                    Text("Calculating...")
                                    ProgressView()
                                        .controlSize(.small)
                                } else {
                                    Text("Calculate")
                                    Image(systemName: "arrow.clockwise")
                                }
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
        Task(priority: .userInitiated) {
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
    }
}

#Preview {
    StorageView(viewModel: .init(directory: .developerDiskImages))
}
