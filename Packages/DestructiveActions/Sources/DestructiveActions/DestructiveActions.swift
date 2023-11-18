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
    
    func delete(coreSimDevice: CoreSimulatorDevice) throws {
        Log.logger.info("⌫ deleting core sim device: [\(coreSimDevice.name)](\(coreSimDevice.root)), uuid: \(coreSimDevice.uuid.uuidString)")
        let rootDirUrl = coreSimDevice.root
        do {
            try self.trashItem(at: rootDirUrl, resultingItemURL: nil)
            coreSimDevice.devicePlist?.isDeleted = true
//            try self.removeItem(at: rootDirUrl)
        } catch {
            throw DestructiveActionError.deleteCoreSimDevice(error)
        }
    }
}
