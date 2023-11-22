import Foundation
import CoreSimulatorTools
import os

struct Log {
    static let logger: Logger = .init()
}

public enum DestructiveActionError: LocalizedError {
    case deleteCoreSimDevice(Error)
    
    public var errorDescription: String? {
        switch self {
        case .deleteCoreSimDevice(let error):
            error.localizedDescription
        }
    }
}

public extension FileManager {
    
    /// - Parameter moveToTrash: If `true` moves device to system Trash bin, otherwise permanently removes device with no recovery options.
    func delete(coreSimDevice: CoreSimulatorDevice, moveToTrash: Bool = true) throws {
        Log.logger.info("⌫ deleting core sim device: [\(coreSimDevice.name)](\(coreSimDevice.root)), uuid: \(coreSimDevice.uuid.uuidString)")
        let rootDirUrl = coreSimDevice.root
        do {
            if moveToTrash {
                try self.trashItem(at: rootDirUrl, resultingItemURL: nil)
            } else {
                try self.removeItem(at: rootDirUrl)
            }
            coreSimDevice.devicePlist?.isDeleted = true
        } catch {
            throw DestructiveActionError.deleteCoreSimDevice(error)
        }
    }
}
