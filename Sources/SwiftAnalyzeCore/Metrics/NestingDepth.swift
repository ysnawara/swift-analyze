import Foundation

/// Calculates the maximum nesting depth within a function body.
///
/// Nesting depth measures how deeply nested the code structure is.
/// Each opening brace `{` increases depth, each closing brace `}` decreases it.
/// The function's own brace is NOT counted (starts at depth 0 inside the function).
///
/// Example: `if { for { if { } } }` has max nesting depth of 3.
public enum NestingDepth {
    /// Calculates the maximum nesting depth from a function body string.
    public static func calculate(for body: String) -> Int {
        let lines = body.components(separatedBy: "\n")
        var maxDepth = 0
        var currentDepth = -1 // Start at -1 because function's own `{` brings it to 0

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Skip comments
            if trimmed.hasPrefix("//") || trimmed.hasPrefix("/*") || trimmed.hasPrefix("*") {
                continue
            }

            // Strip string literals to avoid counting braces in strings
            let stripped = stripStrings(trimmed)

            for char in stripped {
                if char == "{" {
                    currentDepth += 1
                    if currentDepth > maxDepth {
                        maxDepth = currentDepth
                    }
                } else if char == "}" {
                    currentDepth -= 1
                }
            }
        }

        return max(0, maxDepth)
    }

    /// Strips string literal contents to avoid counting braces inside strings.
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
