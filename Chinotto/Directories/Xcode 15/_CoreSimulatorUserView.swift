//
//  _CoreSimulatorUserView.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-14.
//

import SwiftUI

struct _CoreSimulatorUserView: View {
    
    @State private var showInspectorView = false
    
    var body: some View {
        List {
            Section {
                EmptyView()
            } header: {
                Text("/CoreSimulator")
            }
            
            ForEach(CoreSimulator_User.allCases) { value in
                Section {
                    NavigationLink(value: value) {
                        GroupBox {
                            VStack {
                                HStack {
                                    Text("/\(value.dirName)")
                                        .fontWeight(.bold)
                                    Spacer()
                                }
                                Divider()
                                HStack {
                                    Text("\(value.dirDescription)")
                                        .fontWeight(.medium)
                                    Spacer()
                                }
                            }
                            .padding(2)
                        }
                    }
                    .onTapGesture {
                        showInspectorView = true
                    }
                }
            }
        }
        .listStyle(.inset)
        .inspector(isPresented: $showInspectorView) {
            Text("Inspector View")
                .inspectorColumnWidth(min: 320, ideal: 800)
        }
    }
}

#Preview {
    _CoreSimulatorUserView()
}
