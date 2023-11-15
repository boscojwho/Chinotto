//
//  Directories.swift
//  Chinotto
//
//  Created by Bosco Ho on 2023-11-12.
//

import Foundation
import SwiftUI
import Charts

/// A non-exhaustive list of top-level directories in `/Developer`.
enum Directories: CaseIterable, Identifiable {
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
                let size = URL.directorySize(url: directory.url)
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

extension URL {
    /// check if the URL is a directory and if it is reachable
    func isDirectoryAndReachable() throws -> Bool {
        guard try resourceValues(forKeys: [.isDirectoryKey]).isDirectory == true else {
            return false
        }
        return try checkResourceIsReachable()
    }
    
    /// returns total allocated size of a the directory including its subFolders or not
    func directoryTotalAllocatedSize(includingSubfolders: Bool = false) throws -> Int? {
        guard try isDirectoryAndReachable() else { return nil }
        if includingSubfolders {
            guard
                let urls = FileManager.default.enumerator(at: self, includingPropertiesForKeys: nil)?.allObjects as? [URL] else { return nil }
            return try urls.lazy.reduce(0) {
                (try $1.resourceValues(forKeys: [.totalFileAllocatedSizeKey]).totalFileAllocatedSize ?? 0) + $0
            }
        }
        return try FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil).lazy.reduce(0) {
            (try $1.resourceValues(forKeys: [.totalFileAllocatedSizeKey])
                .totalFileAllocatedSize ?? 0) + $0
        }
    }
    
    /// returns the directory total size on disk
    func sizeOnDisk() throws -> String? {
        guard let size = try directoryTotalAllocatedSize(includingSubfolders: true) else { return nil }
        URL.byteCountFormatter.countStyle = .file
        guard let byteCount = URL.byteCountFormatter.string(for: size) else { return nil}
        return byteCount + " on disk"
    }
    private static let byteCountFormatter = ByteCountFormatter()
    
    func volumeTotalCapacity() -> Int? {
        let value = try? self.resourceValues(forKeys: [.volumeTotalCapacityKey])
        return value?.volumeTotalCapacity
    }
}

extension URL {
    
    /// Counts the number of files at this path, including files in all sub-directories.
    static func directoryContentsCount(url: URL) -> Int {
        let contents: [URL]
        do {
            contents = try FileManager.default.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [.isRegularFileKey, .isDirectoryKey],
                options: .skipsPackageDescendants /// Not sure if `.skipsPackageDescendants` is wise here.
            )
        } catch {
            return 0
        }
        
        var count = 0
        
        autoreleasepool {
            for url in contents {
                count += url.hasDirectoryPath ? directoryContentsCount(url: url) : 1
            }
        }
        
        return count
    }
    
    /// This is way faster and uses less memory than using FileManager's enumerator.
    static func directorySize(url: URL) -> Int {
        let contents: [URL]
        do {
            contents = try FileManager.default.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey],
                options: .skipsPackageDescendants /// Not sure if `.skipsPackageDescendants` is wise here.
            )
        } catch {
            return 0
        }
        
        var size: Int = 0
        
        autoreleasepool {
            for url in contents {
                if url.hasDirectoryPath {
                    size += directorySize(url: url)
                } else {
                    let fileSizeResourceValue: URLResourceValues
                    do {
                        fileSizeResourceValue = try url.resourceValues(forKeys: [.fileSizeKey])
                    } catch {
                        continue
                    }
                    
                    size += fileSizeResourceValue.fileSize ?? 0
                }
            }
        }
        
        return size
    }
}
