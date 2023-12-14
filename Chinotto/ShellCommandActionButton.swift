//
//  ShellCommandActionButton.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-12-14.
//

import SwiftUI

struct ShellCommandActionButton: View {
    let shellCommand: ShellCommand
    init(shellCommand: ShellCommand) {
        self.shellCommand = shellCommand
    }
    
    @State private var isPresentingConfirmationAlert: Bool = false
    @State private var isRunning = false
    @State private var commandError: Error? = nil
    
    var body: some View {
        VStack {
            Button {
                isPresentingConfirmationAlert = true
            } label: {
                Text("Delete all \"unavailable\" devices...")
            }
            .buttonStyle(.borderedProminent)
            .tint(.accentColor)
            .disabled(isRunning)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert(
            "Are you sure you want to delete all \"unavailable\" devices?",
            isPresented: $isPresentingConfirmationAlert
        ) {
            Button("Delete...", role: .destructive) {
                let executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
                self.isRunning = true
                do {
                    try Process.run(
                        executableURL,
                        arguments: ["simctl", "delete", "unavailable"],
                        terminationHandler: { _ in self.isRunning = false })
                } catch {
                    commandError = error
                }
            }
            
            Button("Cancel", role: .cancel) {
                
            }
        } message: {
            Text("This will run the following command\n\n`xcrun simctl delete unavailable`\n\nAll devices that don't have an available runtime will be deleted.\n\nEnsure you have backed up all data in these simulator devices before proceeding.")
        }
    }
}

#Preview {
    ShellCommandActionButton(shellCommand: XCRun.Simctl.DeleteUnavailable())
}
