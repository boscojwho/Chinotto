//
//  Directories.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-12.
//

import Foundation
import SwiftUI
import Charts
import FileSystem

/// A non-exhaustive list of top-level directories in `/Developer`.
enum Directories: CaseIterable, Identifiable, Codable {
    case coreSimulator
    case developerDiskImages
    case toolchains
    
    case xcode
    case xcPGDevices
    case xcTestDevices
    
    var id: String { dirName }
    
    /// Base path for `/Developer` directory in current user's directory.
    static var userBasePath: String {
        "/Users/\(NSUserName())/Library/Developer"
    }
    
    /// Base path for `/Developer` directory not associated with any user.
    static var systemBasePath: String {
        "/Library/Developer"
    }
    
    var dirName: String {
        switch self {
        case .coreSimulator:
            "CoreSimulator"
        case .developerDiskImages:
            "DeveloperDiskImages"
        case .toolchains:
            "Toolchains"
        case .xcode:
            "Xcode"
        case .xcPGDevices:
            "XCPGDevices"
        case .xcTestDevices:
            "XCTestDevices"
        }
    }
    
    var path: String {
        "\(Self.userBasePath)/\(dirName)"
    }
    
    var systemPath: String {
        "\(Self.systemBasePath)/\(dirName)"
    }
    
    func path(scope: DirectoryScope) -> String {
        switch scope {
        case .system:
            systemPath
        case .user:
            path
        }
    }
    
    var systemImage: String {
        switch self {
        case .coreSimulator:
            "apps.iphone"
        case .developerDiskImages:
            "externaldrive.fill"
        case .toolchains:
            "screwdriver"
        case .xcode:
            "wrench.and.screwdriver.fill"
        case .xcPGDevices:
            "circle.filled.iphone"
        case .xcTestDevices:
            "circle.filled.iphone.fill"
        }
    }
}

extension Directories {
    
    var accentColor: Color {
        switch self {
        case .coreSimulator:
            Color.orange
        case .developerDiskImages:
            Color.purple
        case .toolchains:
            .teal
        case .xcode:
            Color.blue
        case .xcPGDevices:
            Color.pink
        case .xcTestDevices:
            Color.mint
        }
    }
}

extension Directories: Plottable {
    var primitivePlottable: String {
        dirName
    }
    
    init?(primitivePlottable: String) {
        if let match = Directories.allCases.first(where: { $0.dirName == primitivePlottable }) {
            self = match
        } else {
            return nil
        }
    }
    
    typealias PrimitivePlottable = String
    
    
}

final class Directory: Equatable {
    
    let fileManager = FileManager.default
    let path: String
    let url: URL
    
    init(directory: Directories) {
        self.path = directory.path
        self.url = URL(filePath: self.path, directoryHint: .isDirectory)
    }
    
    func readDirectory() throws -> [URL] {
        do {
            let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            return contents
        } catch {
            print("Error: \(error)")
            throw error
        }
    }
    
    func calculateDirectorySize(atPath path: String) -> UInt64 {
        let fileManager = FileManager.default
        var totalSize: UInt64 = 0
        
        if let enumerator = fileManager.enumerator(atPath: path) {
            for file in enumerator {
                if let filePath = file as? String {
                    let fileAttributes = try? fileManager.attributesOfItem(atPath: "\(path)/\(filePath)")
                    if let fileType = fileAttributes?[FileAttributeKey.type] as? FileAttributeType,
                       fileType == .typeRegular {
                        if let fileSize = fileAttributes?[FileAttributeKey.size] as? UInt64 {
                            print("\(fileSize) -> \(filePath)")
                            totalSize += fileSize
                        }
                    } else if let fileType = fileAttributes?[FileAttributeKey.type] as? FileAttributeType,
                              fileType == .typeDirectory {
                        let subdirectoryPath = "\(path)/\(filePath)"
                        print("hit subdir -> \(subdirectoryPath)")
                        totalSize += calculateDirectorySize(atPath: subdirectoryPath)
                    }
                }
            }
        }
        
        print("\(totalSize) at \(path)")
        return totalSize
    }
    
    static func == (lhs: Directory, rhs: Directory) -> Bool {
        lhs.path == rhs.path
    }
}

@Observable final class DirectoryViewModel {
    
    var directory: Directory
    var contents: [URL] = []
    var directorySize: UInt64?
    
    init(directory: Directory) {
        self.directory = directory
    }
    
    func reloadContents() {
        do {
            contents = try directory.readDirectory()
        } catch {
            print(error)
        }
    }
    
    func calculateDirectorySize() async {
        Task(priority: .utility) {
            do {
//                let size = directory.calculateDirectorySize(atPath: directory.path)
//                let size = try directory.url.directoryTotalAllocatedSize(includingSubfolders: true)
                
                var dirMetadata: [URL: Int] = [:]
                var fileMetadata: [URL: Int] = [:]
                let size = URL.directorySize(url: directory.url, dirMetadata: &dirMetadata, fileMetadata: &fileMetadata)
                Task { @MainActor in
                    directorySize = .init(integerLiteral: UInt64(size ?? 0))
                }
            } catch {
                print(error)
            }
        }
    }
    
    func byteSize() -> String {
        let size = directorySize ?? 0
        return formatSize(size)
    }
    
    private func formatSize(_ size: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(size))
    }
}
