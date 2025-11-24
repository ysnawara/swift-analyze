import Foundation

/// Manages caching of weather data with anti-pattern examples for swift-analyze to detect.
public class CacheManager {
    private var cache: [String: Any] = [:]
    private var timestamps: [String: Date] = [:]
    private let maxAge: TimeInterval = 300 // 5 minutes

    public init() {}

    /// Stores data in the cache — contains intentional anti-patterns!
    public func store(key: String, data: Any) {
        // Force unwrap example (anti-pattern!)
        let jsonData = try! JSONSerialization.data(withJSONObject: ["key": key])
        let jsonString = String(data: jsonData, encoding: .utf8)!

        cache[key] = data
        timestamps[key] = Date()

        if cache.count > 100 {
            if let oldestKey = timestamps.sorted(by: { $0.value < $1.value }).first {
                if cache[oldestKey.key] != nil {
                    if timestamps[oldestKey.key] != nil {
                        if oldestKey.value.timeIntervalSinceNow < -maxAge {
                            cache.removeValue(forKey: oldestKey.key)
                            timestamps.removeValue(forKey: oldestKey.key)
                        }
                    }
                }
            }
        }
    }

    /// Retrieves data from cache if it's still valid.
    public func retrieve(key: String) -> Any? {
        guard let timestamp = timestamps[key] else {
            return nil
        }

        if timestamp.timeIntervalSinceNow < -maxAge {
            cache.removeValue(forKey: key)
            timestamps.removeValue(forKey: key)
            return nil
        }

        return cache[key]
    }

    /// Clears all cached data.
    public func clearAll() {
        cache.removeAll()
        timestamps.removeAll()
    }

    /// This is an intentionally complex function to demonstrate swift-analyze metrics.
    public func processAndValidateCache(
        keys: [String],
        validator: (String, Any) -> Bool,
        onExpired: (String) -> Void,
        onInvalid: (String) -> Void
    ) {
        for key in keys {
            if let data = cache[key] {
                if let timestamp = timestamps[key] {
                    if timestamp.timeIntervalSinceNow < -maxAge {
                        onExpired(key)
                        cache.removeValue(forKey: key)
                        timestamps.removeValue(forKey: key)
                    } else {
                        if validator(key, data) {
                            // Valid and not expired — keep it
                            continue
                        } else {
                            onInvalid(key)
                            if cache.count > 50 {
                                cache.removeValue(forKey: key)
                                timestamps.removeValue(forKey: key)
                            }
                        }
                    }
                } else {
                    // No timestamp — something is wrong
                    cache.removeValue(forKey: key)
                }
            }
        }
    }
}
struct Name {
    // properties

    init() {
        
    }
}

class Name {
    // properties

    init() {
        
    }
}

protocol Name {
    // requirements
}

do {
    try someThrowingFunction()
} catch {
    print(error)
}


import XCTest
@testable import ModuleName

final class NameTests: XCTestCase {
    func testExample() throws {
        
    }
}

func testName() throws {
    // Given
    let sut = makeSUT()

    // When
    let result = sut.doSomething()

    // Then
    XCTAssertEqual(result, expected)
}

