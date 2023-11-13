//
//  StorageView.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-12.
//

import SwiftUI
import Charts

@Observable
final class StorageViewModel {
    
    let directory: Directories
    init(directory: Directories) {
        self.directory = directory
        self.volumeTotalCapacity = URL(filePath: directory.path, directoryHint: .isDirectory).volumeTotalCapacity()
    }
    
    var isCalculating = false
    
    var volumeTotalCapacity: Int?
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
    func calculateSize(initial: Bool) {
        if initial {
            if dirSize != 0 {
                return
            }
        }
        
        isCalculating = true
        let size = URL.directorySize(url: .init(filePath: directory.path, directoryHint: .isDirectory))
        self.dirSize = size
        isCalculating = false
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
    
    @State private var viewModel: StorageViewModel = .init(directory: .coreSimulator)
    
    var body: some View {
        VStack {
            HStack {
                Text("\(viewModel.directory.dirName)")
                Spacer()
                Text("\(viewModel.dirSizeFormattedString) of \(viewModel.volumeTotalCapacityFormattedString)")
            }
            chartView()
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
        .chartXAxisLabel {
            Text("Disk Space Used")
        }
        .chartYAxis(.hidden)
//        .chartYScale(range: .plotDimension(endPadding: -8))
//        .chartLegend(position: .top, spacing: 8)
        .chartLegend(.hidden)
        .frame(height: 64)
        .onAppear {
            viewModel.calculateSize(initial: true)
        }
    }
}

#Preview {
    StorageView(directory: .developerDiskImages)
}
