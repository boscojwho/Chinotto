//
//  AppSidebarView.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-16.
//

import SwiftUI

struct AppSidebarView: View {
    var body: some View {
        List {
            Section {
                NavigationLink {
                    Text("Home")
                } label: {
                    HStack {
                        Image(systemName: "house")
                            .symbolVariant(.fill)
                        Text("Home")
                    }
                }
            }
        }
    }
}

#Preview {
    AppSidebarView()
}
