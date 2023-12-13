//
//  CleanButton.swift
//
//
//  Created by Bosco Ho on 2023-12-12.
//

import SwiftUI

public struct CleanButton: View {
    @Binding var loading: Bool
    private let action: () -> Void
    
    public init(loading: Binding<Bool>, action: @escaping () -> Void) {
        self._loading = loading
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            action()
        }, label: {
            TextIconButtonLabel(
                text: Text("Clean"),
                iconSystemName: "bubbles.and.sparkles",
                loading: $loading,
                loadingText: "Cleaning..."
            )
        })
        .tint(.green)
        .buttonStyle(.borderedProminent)
    }
}

#Preview {
    VStack {
        CleanButton(loading: .constant(false), action: {})
        CleanButton(loading: .constant(true), action: {})
    }
}
