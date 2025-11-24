import Foundation

/// Raw function information extracted from Swift source before metric analysis.
public struct RawFunctionInfo {
    public let name: String
    public let startLine: Int
    public let endLine: Int
    public let body: String
}

/// Parses Swift source code to extract function definitions.
/// Uses regex-based parsing to identify function boundaries
/// by tracking brace depth.
public enum SwiftParser {
    /// Extracts all functions from a Swift source string.
    public static func extractFunctions(from content: String, filePath: String) -> [RawFunctionInfo] {
        let lines = content.components(separatedBy: "\n")
        var functions: [RawFunctionInfo] = []

        var i = 0
        while i < lines.count {
            let line = lines[i]
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Skip comments and empty lines
            if trimmed.isEmpty || trimmed.hasPrefix("//") || trimmed.hasPrefix("/*") {
                i += 1
                continue
            }

            // Check if this line contains a function declaration
            // Look for `func` keyword that's NOT inside a string literal
            let stripped = stripStringLiterals(trimmed)
            let hasFuncKeyword = stripped.range(of: #"\bfunc\s+\w+"#, options: .regularExpression) != nil
            let hasInit = stripped.range(of: #"\binit\s*\("#, options: .regularExpression) != nil
            let hasDeinit = stripped.range(of: #"\bdeinit\s*\{"#, options: .regularExpression) != nil

            if hasFuncKeyword || hasInit || hasDeinit {
                // Extract function name
                let name = extractFunctionName(from: trimmed) ?? "anonymous"

                // Find the opening brace (might be on this line or following lines)
                var braceStart = i
                while braceStart < lines.count && !lines[braceStart].contains("{") {
                    braceStart += 1
                }

                if braceStart >= lines.count {
                    i += 1
                    continue
                }

                // Track braces to find the function's closing brace
                var depth = 0
                var bodyLines: [String] = []
                var j = braceStart

                while j < lines.count {
                    let currentLine = lines[j]
                    let strippedLine = stripStringLiterals(currentLine)

                    for char in strippedLine {
                        if char == "{" { depth += 1 }
                        if char == "}" { depth -= 1 }
                    }

                    bodyLines.append(currentLine)

                    if depth == 0 {
                        break
                    }
                    j += 1
                }

                let startLine = i + 1  // 1-indexed
                let endLine = j + 1    // 1-indexed

                // Only include functions with meaningful body
                if bodyLines.count >= 1 {
                    functions.append(RawFunctionInfo(
                        name: name,
                        startLine: startLine,
                        endLine: endLine,
                        body: bodyLines.joined(separator: "\n")
                    ))
                }

                i = j + 1
                continue
            }

            i += 1
        }

        return functions
    }

    /// Extracts the function name from a declaration line.
    private static func extractFunctionName(from line: String) -> String? {
        // Match func keyword followed by name
        if let range = line.range(of: #"func\s+(\w+)"#, options: .regularExpression) {
            let match = String(line[range])
            let parts = match.split(separator: " ", maxSplits: 2)
            if parts.count >= 2 {
                return String(parts[1])
            }
        }

        // Match init / deinit
        if line.contains("init(") || line.contains("init {") {
            return "init"
        }
        if line.contains("deinit") {
            return "deinit"
        }

        return nil
    }

    /// Strips string literal content to avoid counting braces inside strings.
    /// Replaces contents between quotes with spaces.
    private static func stripStringLiterals(_ line: String) -> String {
        var result = ""
        var inString = false
        var prevChar: Character = " "

        for char in line {
            if char == "\"" && prevChar != "\\" {
                inString.toggle()
                result.append(char)
            } else if inString {
                result.append(" ")  // Replace string content with space
            } else {
                result.append(char)
            }
            prevChar = char
        }

        return result
    }
}
