import Foundation

/// Recursively discovers Swift source files in a given path.
public enum FileScanner {
    /// Finds all .swift files at the given path.
    /// If `path` is a file, returns it directly.
    /// If `path` is a directory, returns all .swift files within it
    /// (recursively if `recursive` is true).
    public static func findSwiftFiles(at path: String, recursive: Bool) -> [String] {
        let fileManager = FileManager.default
        var isDir: ObjCBool = false

        guard fileManager.fileExists(atPath: path, isDirectory: &isDir) else {
            return []
        }

        // Single file
        if !isDir.boolValue {
            return path.hasSuffix(".swift") ? [path] : []
        }

        // Directory
        if recursive {
            return findFilesRecursively(in: path, fileManager: fileManager)
        } else {
            return findFilesInDirectory(path, fileManager: fileManager)
        }
    }

    private static func findFilesRecursively(
        in directory: String,
        fileManager: FileManager
    ) -> [String] {
        var results: [String] = []

        guard let enumerator = fileManager.enumerator(atPath: directory) else {
            return results
        }

        while let relativePath = enumerator.nextObject() as? String {
            if relativePath.hasSuffix(".swift") {
                let fullPath = (directory as NSString).appendingPathComponent(relativePath)
                results.append(fullPath)
            }
        }

        return results.sorted()
    }

    private static func findFilesInDirectory(
        _ directory: String,
        fileManager: FileManager
    ) -> [String] {
        guard let entries = try? fileManager.contentsOfDirectory(atPath: directory) else {
            return []
        }

        return entries
            .filter { $0.hasSuffix(".swift") }
            .map { (directory as NSString).appendingPathComponent($0) }
            .sorted()
    }
}
