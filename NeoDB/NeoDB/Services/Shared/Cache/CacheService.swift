import Foundation
import OSLog
import Cache

@MainActor
class CacheService {
    private let logger = Logger.cache
    
    // Default configurations
    private let defaultMemoryConfig = MemoryConfig(
        expiry: .date(Date().addingTimeInterval(12 * 60 * 60)), // 12 hours
        countLimit: 50,
        totalCostLimit: 50 * 1024 * 1024 // 50 MB
    )
    
    private let defaultDiskConfig = DiskConfig(
        name: "NeoDB",
        expiry: .date(Date().addingTimeInterval(7 * 24 * 60 * 60)), // 7 days
        maxSize: 512 * 1024 * 1024 // 512 MB
    )
    
    private let defaultFileManager = FileManager.default
    
    // Type-safe storage instances
    private var storages: [String: Any] = [:]
    
    // Create storage for a specific type
    func storage<T: Codable>(for type: T.Type, name: String) throws -> Storage<String, T> {
        if let existing = storages[name] as? Storage<String, T> {
            return existing
        }
        
        let diskConfig = DiskConfig(
            name: name,
            expiry: defaultDiskConfig.expiry,
            maxSize: defaultDiskConfig.maxSize
        )
        
        let storage = try Storage<String, T>(
            diskConfig: diskConfig,
            memoryConfig: defaultMemoryConfig,
            fileManager: defaultFileManager,
            transformer: TransformerFactory.forCodable(ofType: T.self)
        )
        
        storages[name] = storage
        return storage
    }
    
    // Generic methods for cache operations
    func cache<T: Codable>(_ item: T, forKey key: String, type: T.Type) async throws {
        let storage = try storage(for: type, name: String(describing: type))
        try storage.setObject(item, forKey: key)
        logger.debug("Cached item of type \(type) with key: \(key)")
    }
    
    func retrieve<T: Codable>(forKey key: String, type: T.Type) async throws -> T? {
        let storage = try storage(for: type, name: String(describing: type))
        let item = try storage.object(forKey: key)
        logger.debug("Retrieved item of type \(type) with key: \(key)")
        return item
    }
    
    func remove<T: Codable>(forKey key: String, type: T.Type) async throws {
        let storage = try storage(for: type, name: String(describing: type))
        try storage.removeObject(forKey: key)
        logger.debug("Removed item of type \(type) with key: \(key)")
    }
    
    func removeExpired() async {
        for (name, storage) in storages {
            if let typedStorage = storage as? any StorageAware {
                try? typedStorage.removeExpiredObjects()
                logger.debug("Removed expired items from \(name) storage")
            }
        }
    }
    
    func removeAll() async {
        for (name, storage) in storages {
            if let typedStorage = storage as? any StorageAware {
                try? typedStorage.removeAll()
                logger.debug("Cleared all items from \(name) storage")
            }
        }
        storages.removeAll()
    }
} 
