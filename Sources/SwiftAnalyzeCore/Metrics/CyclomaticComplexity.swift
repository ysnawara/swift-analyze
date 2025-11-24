import Foundation

/// Calculates cyclomatic complexity for a function body.
///
/// Cyclomatic complexity counts the number of linearly independent paths
/// through the code. Base complexity is 1, and each decision point adds 1.
///
/// Decision points counted:
/// - `if`, `else if`, `guard` (conditional branches)
/// - `case` in switch statements
/// - `for`, `while`, `repeat` (loops)
/// - `catch` (error handling)
/// - `&&`, `||`, `??` (boolean/nil-coalescing operators)
public enum CyclomaticComplexity {
    /// Calculates cyclomatic complexity from a function body string.
    public static func calculate(for body: String) -> Int {
        var complexity = 1 // Base complexity

        let lines = body.components(separatedBy: "\n")

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Skip comments
            if trimmed.hasPrefix("//") || trimmed.hasPrefix("/*") || trimmed.hasPrefix("*") {
                continue
            }

            // Skip string literals for accuracy
            let stripped = stripStrings(trimmed)

            // Conditional branches
            if matches(stripped, pattern: #"\bif\b"#) { complexity += 1 }
            if matches(stripped, pattern: #"\belse\s+if\b"#) {
                // Already counted by `if` above, but `else if` is a single
                // construct — we only count the `if`, so subtract the extra
                // No action needed: the `if` regex already matched
            }
            if matches(stripped, pattern: #"\bguard\b"#) { complexity += 1 }

            // Switch cases (each case is a path)
            if matches(stripped, pattern: #"\bcase\b"#) { complexity += 1 }

            // Loops
            if matches(stripped, pattern: #"\bfor\b"#) { complexity += 1 }
            if matches(stripped, pattern: #"\bwhile\b"#) { complexity += 1 }
            if matches(stripped, pattern: #"\brepeat\b"#) { complexity += 1 }

            // Error handling
            if matches(stripped, pattern: #"\bcatch\b"#) { complexity += 1 }

            // Boolean operators (each one adds a path)
            complexity += countOccurrences(of: "&&", in: stripped)
            complexity += countOccurrences(of: "||", in: stripped)

            // Nil-coalescing operator
            complexity += countOccurrences(of: "??", in: stripped)
        }

        return complexity
    }

    /// Checks if a string matches a regex pattern.
    private static func matches(_ text: String, pattern: String) -> Bool {
        return text.range(of: pattern, options: .regularExpression) != nil
    }

    /// Counts non-overlapping occurrences of a substring.
    private static func countOccurrences(of target: String, in text: String) -> Int {
        var count = 0
        var searchRange = text.startIndex..<text.endIndex

        while let range = text.range(of: target, range: searchRange) {
            count += 1
            searchRange = range.upperBound..<text.endIndex
        }

        return count
    }

    /// Strips string literal contents to avoid false positive keyword matches.
    private static func stripStrings(_ line: String) -> String {
        var result = ""
        var inString = false
        var prev: Character = " "

        for char in line {
            if char == "\"" && prev != "\\" {
                inString.toggle()
                result.append(char)
            } else if inString {
                result.append(" ")
            } else {
                result.append(char)
            }
            prev = char
        }

        return result
    }
}
