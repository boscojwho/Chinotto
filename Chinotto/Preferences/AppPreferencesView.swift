//
//  AppPreferencesView.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-14.
//

import SwiftUI

/// App Preferences (Settigns).
struct AppPreferencesView: View {

    private enum Tabs: Hashable {
        case general, advanced
    }

    @State private var selectedTab: Tabs = .general
    
    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralPreferencesView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(Tabs.general)
        }
        .frame(minWidth: 480, minHeight: 320)
    }
}

#Preview {
    AppPreferencesView()
}
