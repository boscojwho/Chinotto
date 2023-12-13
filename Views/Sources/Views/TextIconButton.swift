//
//  TextIconButtonLabel.swift
//
//
//  Created by Bosco Ho on 2023-12-12.
//

import SwiftUI

public struct TextIconButtonLabel<Title: View>: View {
    let titleText: Title
    private let iconSystemName: String?
    private let iconName: String?
    
    @Binding var loading: Bool
    let loadingText: String?
    
    public init(
        text: Title,
        iconSystemName: String? = "",
        iconName: String? = "",
        loading: Binding<Bool>? = nil,
        loadingText: String? = ""
    ) {
        self.titleText = text
        self.iconSystemName = iconSystemName
        self.iconName = iconName
        _loading = loading ?? .constant(false)
        self.loadingText = loadingText
    }
    
    public var body: some View {
        HStack {
            if loading, let loadingText {
                Text(loadingText)
                ProgressView()
                    .controlSize(.small)
            } else {
                titleText
                if let iconSystemName {
                    Image(systemName: iconSystemName)
                } else if let iconName {
                    Image(iconName)
                }
            }
        }
    }
}

#Preview {
    Button(action: {}, label: {
        TextIconButtonLabel(
            text: Text("Clean..."),
            iconSystemName: "bubbles.and.sparkles"
        )
    })
}

#Preview {
    Button(action: {}, label: {
        TextIconButtonLabel(
            text: Text("Clean..."),
            iconSystemName: "bubbles.and.sparkles",
            loading: .constant(true),
            loadingText: "Cleaning..."
        )
    })
}
