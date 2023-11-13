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
        VStack {
            GroupBox {
                chartView()
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
                .foregroundStyle(by: .value("Data Category", value.directory.dirName))
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
        .frame(height: 64)
        .onAppear {
            viewModels.forEach { $0.calculateSize(initial: false, recalculate: false) }
        }
    }
}

#Preview {
    UnifiedStorageView()
}
