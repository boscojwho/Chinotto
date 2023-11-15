//
//  CoreSimDevice.swift
//
//
//  Created by Bosco Ho on 2023-11-15.
//

import Foundation

public struct DevicePlist: Codable, Identifiable {
    public let UDID: String
    public let deviceType: String
    public let isDeleted: Bool
    public let isEphemeral: Bool
    public let name: String
    public let runtime: String
    public let runtimePolicy: String
    public let state: Int
    
    public var id: String { UDID }
}

@Observable
public final class CoreSimulatorDevice: Identifiable, Codable, Hashable {
    public static func == (lhs: CoreSimulatorDevice, rhs: CoreSimulatorDevice) -> Bool {
        lhs.uuid == rhs.uuid
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
    
    public let uuid: UUID
    public let plist: URL
    public let data: URL
    
    public init(uuid: UUID, plist: URL, data: URL) {
        self.uuid = uuid
        self.plist = plist
        self.data = data
        
        Task {
            await decodePlist()
        }
    }
    
    public var devicePlist: DevicePlist?
    
    private func decodePlist() async {
        guard let plistData = FileManager.default.contents(atPath: plist.path()) else {
            return
        }
        
        do {
            let value = try PropertyListDecoder().decode(DevicePlist.self, from: plistData)
            Task { @MainActor in
                devicePlist = value
            }
        } catch {
            print(error)
        }
    }
}
