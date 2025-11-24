import Foundation

/// Detects common anti-patterns in Swift function bodies.
public enum AntiPatternDetector {
    /// Detects anti-patterns in a function body.
    ///
    /// - Parameters:
    ///   - body: The function body source code
    ///   - startLine: The starting line number of the function
    ///   - lineCount: Total lines in the function
    ///   - nestingDepth: Pre-calculated max nesting depth
    public static func detect(
        in body: String,
        startLine: Int,
        lineCount: Int,
        nestingDepth: Int
    ) -> [AntiPattern] {
        var patterns: [AntiPattern] = []
        let lines = body.components(separatedBy: "\n")

        // Check each line for anti-patterns
        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            let absoluteLine = startLine + index

            // Skip comments
            if trimmed.hasPrefix("//") || trimmed.hasPrefix("/*") || trimmed.hasPrefix("*") {
                continue
            }

            // Detect force unwraps: variable! (but not != operator)
            if detectForceUnwrap(in: trimmed) {
                patterns.append(AntiPattern(
                    type: .forceUnwrap,
                    line: absoluteLine,
                    description: "Force unwrap detected — consider using optional binding"
                ))
            }

            // Detect force try
            if trimmed.contains("try!") {
                patterns.append(AntiPattern(
                    type: .forceTry,
                    line: absoluteLine,
                    description: "Force try detected — consider using do-catch or try?"
                ))
            }
        }

        // Check function length threshold (> 50 lines)
        if lineCount > 50 {
            patterns.append(AntiPattern(
                type: .longFunction,
                line: startLine,
                description: "Function is \(lineCount) lines — consider breaking it into smaller functions"
            ))
        }

        // Check nesting depth threshold (> 4 levels)
        if nestingDepth > 4 {
            patterns.append(AntiPattern(
                type: .deepNesting,
                line: startLine,
                description: "Max nesting depth is \(nestingDepth) — consider using guard or early return"
            ))
        }

        return patterns
    }

    /// Detects force unwrap patterns while avoiding false positives from != operator.
    ///
    /// Matches patterns like: `value!`, `array[0]!`, `dict["key"]!`
    /// Excludes: `!=`, `!==`, `!condition` (logical not)
    private static func detectForceUnwrap(in line: String) -> Bool {
        // Pattern: identifier or closing bracket/paren followed by !
        // but NOT followed by = (which would be !=)
        let pattern = #"[\w\]\)]\!(?!=)"#
        return line.range(of: pattern, options: .regularExpression) != nil
    }
}
