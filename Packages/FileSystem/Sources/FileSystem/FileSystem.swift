// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public extension URL {
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

public extension URL {
    
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
    static func directorySize(url: URL, dirMetadata: inout [URL: Int], fileMetadata: inout [URL: Int]) -> Int {
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
                    let s = directorySize(url: url, dirMetadata: &dirMetadata, fileMetadata: &fileMetadata)
                    if s != 0 {
                        dirMetadata[url] = s
                    }
                    size += s
                } else {
                    let fileSizeResourceValue: URLResourceValues
                    do {
                        fileSizeResourceValue = try url.resourceValues(forKeys: [.fileSizeKey])
                    } catch {
                        continue
                    }
                    
                    let s = fileSizeResourceValue.fileSize ?? 0
                    if s != 0 {
                        fileMetadata[url] = s
                    }
                    size += s
                }
            }
        }
        
        return size
    }
    
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
