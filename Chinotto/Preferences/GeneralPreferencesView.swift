//
//  GeneralPreferencesView.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-21.
//

import SwiftUI
import DestructiveActions

struct GeneralPreferencesView: View {
    
    @AppStorage("preferences.general.deletionBehaviour") var deletionBehaviour: DeletionBehaviour = .moveToTrash
    
    var body: some View {
        Form {
            Section {
                Picker("Deletion Behavior:", selection: $deletionBehaviour) {
                    ForEach(DeletionBehaviour.allCases) { value in
                        Text(value.description).tag(value)
                    }
                }
                .pickerStyle(.inline)
               
                GroupBox {
                    HStack {
                        Image(systemName: deletionBehaviour.systemImage)
                            .foregroundStyle(deletionBehaviour.accentColor)
                            .fontWeight(.bold)
                        Text(deletionBehaviour.behaviourDescription)
                            .lineLimit(nil)
                    }
                }
                .frame(maxWidth: 320)
            }
        }
    }
}

#Preview {
    GeneralPreferencesView()
        .frame(width: 480, height: 600)
}
