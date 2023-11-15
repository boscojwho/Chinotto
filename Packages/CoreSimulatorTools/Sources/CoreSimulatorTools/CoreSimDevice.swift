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
    
    public var isLoadingDataContents = false
    public var dataContents: DataDir?
    public func loadDataContents() {
        defer { isLoadingDataContents = false }
        isLoadingDataContents = true
        let contents: [URL]
        do {
            contents = try FileManager.default.contentsOfDirectory(
                at: data,
                includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey],
                options: [.skipsPackageDescendants, .skipsHiddenFiles]
            )
            
            let metadata = contents.compactMap {
                let size = URL.directorySize(url: $0)
                return Metadata(url: $0, size: size)
            }
            dataContents = .init(contents: contents, metadata: metadata)
        } catch {
            print(error)
        }
    }
    
    @ObservationIgnored
    public var dirsMetadata: [URL: Int] = [:]
    
    @ObservationIgnored
    public var filesMetadata: [URL: Int] = [:]
}

struct Metadata: Codable, Identifiable {
    let url: URL
    let size: Int
    
    var id: String { url.absoluteString }
}

public final class DataDir: Codable {
    var contents: [URL] = []
    var metadata: [Metadata] = []
    
    init(contents: [URL], metadata: [Metadata]) {
        self.contents = contents
        self.metadata = metadata
    }
}

extension URL {
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
