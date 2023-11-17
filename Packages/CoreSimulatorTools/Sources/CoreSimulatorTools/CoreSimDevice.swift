//
//  CoreSimDevice.swift
//
//
//  Created by Bosco Ho on 2023-11-15.
//

import Foundation

/// Same as `UIUserInterfaceIdiom`.
public enum DeviceIdiom: Int, Sendable, CustomStringConvertible, Comparable {
    public static func < (lhs: DeviceIdiom, rhs: DeviceIdiom) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
    
    case unspecified
    case phone
    case pad
    case watch
    case tv
    case carPlay
    case mac
    case vision

    public var id: Int { rawValue }
    
    public var description: String {
        switch self {
        case .unspecified:
            "Unspecified"
        case .phone:
            "Phone"
        case .pad:
            "Pad"
        case .watch:
            "Watch"
        case .tv:
            "TV"
        case .carPlay:
            "CarPlay"
        case .mac:
            "Mac"
        case .vision:
            "Vision"
        }
    }
    
    public var systemImage: String {
        switch self {
        case .unspecified:
            "questionmark.app"
        case .phone:
            "apps.iphone"
        case .pad:
            "apps.ipad.landscape"
        case .watch:
            "applewatch"
        case .tv:
            "tv"
        case .carPlay:
            "car"
        case .mac:
            "macbook"
        case .vision:
            "visionpro"
        }
    }
}

extension DeviceIdiom {
    static func idiom(for device: DevicePlist) -> Self {
        let deviceName = device.name
        if deviceName.localizedCaseInsensitiveContains("phone") || deviceName.localizedCaseInsensitiveContains("pod") {
            return .phone
        } else if deviceName.localizedCaseInsensitiveContains("pad") {
            return .pad
        } else if deviceName.localizedCaseInsensitiveContains("watch") {
            return .watch
        } else if deviceName.localizedCaseInsensitiveContains("tv") {
            return .tv
        } else if deviceName.localizedCaseInsensitiveContains("carplay") {
            return .carPlay
        } else if deviceName.localizedCaseInsensitiveContains("mac") {
            return .mac
        } else if deviceName.localizedCaseInsensitiveContains("vision") {
            return .vision
        } else {
            return .unspecified
        }
    }
}

public struct DevicePlist: Codable, Identifiable {
    public let UDID: String
    public let deviceType: String
    public let isDeleted: Bool
    public let isEphemeral: Bool
    public let lastBootedAt: Date?
    public let name: String
    public let runtime: String
    public let runtimePolicy: String
    public let state: Int
    
    public var id: String { UDID }
}

extension DevicePlist {
    var userInterfaceIdiom: DeviceIdiom {
        .idiom(for: self)
    }
}

@Observable
public final class CoreSimulatorDevice: Identifiable, Codable, Hashable {
    public static func == (lhs: CoreSimulatorDevice, rhs: CoreSimulatorDevice) -> Bool {
        lhs.uuid == rhs.uuid
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
    
    public let root: URL
    public let uuid: UUID
    public let plist: URL
    public let data: URL
    
    public init(root: URL, uuid: UUID, plist: URL, data: URL) {
        self.root = root
        self.uuid = uuid
        self.plist = plist
        self.data = data
        
        if let values = try? data.resourceValues(forKeys: [.creationDateKey, .contentModificationDateKey]), let creationDate = values.creationDate, let contentModified = values.contentModificationDate {
            dateAdded = creationDate
            lastModified = contentModified
        }
        
        Task {
            await decodePlist()
            loadDataContents()
        }
    }
    
    /// `.creationDateKey`
    public private(set) var dateAdded: Date?
    /// `.contentModificationDateKey`
    public private(set) var lastModified: Date?
    
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
    
    /// Use this key path for APIs that require a non-optional value (e.g. `SwiftUI.TableColumn`).
    public var name: String { devicePlist?.name ?? uuid.uuidString }
    /// Use this key path for APIs that require a non-optional value (e.g. `SwiftUI.TableColumn`).
    public var totalSize: Int { size ?? -1 }
    public var creationDate: Date {
        dateAdded ?? .distantPast
    }
    public var contentModificationDate: Date {
        lastModified ?? .distantPast
    }
    public var deviceKind: DeviceIdiom {
        devicePlist?.userInterfaceIdiom ?? .unspecified
    }
    public var lastBootedAt: Date {
        devicePlist?.lastBootedAt ?? .distantPast
    }
    
    public private(set) var size: Int?
    public var isLoadingDataContents = false
    public var dataContents: DataDir?
    public func loadDataContents(recalculate: Bool = true) {
        defer { isLoadingDataContents = false }
        isLoadingDataContents = true
        
        Task {
            let contents: [URL]
            do {
                contents = try FileManager.default.contentsOfDirectory(
                    at: data,
                    includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey, .creationDateKey, .contentModificationDateKey],
                    options: [.skipsPackageDescendants, .skipsHiddenFiles]
                )
                
                let metadata = contents.compactMap {
                    let values = try? $0.resourceValues(forKeys: [.creationDateKey, .contentModificationDateKey])
                    let size = URL.directorySize(url: $0)
                    return Metadata(
                        url: $0,
                        size: size,
                        dateAdded: values?.creationDate,
                        lastModified: values?.contentModificationDate
                    )
                }
                Task { @MainActor in
                    dataContents = .init(contents: contents, metadata: metadata)
                    size = metadata.reduce(0) { $0 + $1.size }
                }
            } catch {
                print(error)
            }
        }
    }
    
    @ObservationIgnored
    public var dirsMetadata: [URL: Int] = [:]
    
    @ObservationIgnored
    public var filesMetadata: [URL: Int] = [:]
}

public struct Metadata: Codable, Identifiable {
    public let url: URL
    public let size: Int
    /// `.creationDateKey`
    public let dateAdded: Date?
    /// `.contentModificationDateKey`
    public let lastModified: Date?
    
    public var id: String { url.absoluteString }
    
    public var key: String {
        url.lastPathComponent
    }
}

public final class DataDir: Codable {
    public var contents: [URL] = []
    public var metadata: [Metadata] = []
    
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
