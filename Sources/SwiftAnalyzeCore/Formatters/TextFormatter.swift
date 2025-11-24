import Foundation

/// Formats analysis results as human-readable text output.
/// Designed to be understandable by beginners and useful for experienced developers.
public enum TextFormatter {
    public static func format(_ result: AnalysisResult) -> String {
        var output = ""

        // Header
        output += "\n"
        output += "╔══════════════════════════════════════════════════════════════════╗\n"
        output += "║                  Swift Code Analysis Report                      ║\n"
        output += "╚══════════════════════════════════════════════════════════════════╝\n\n"

        // Per-file results
        for fileReport in result.files {
            let fileName = (fileReport.filePath as NSString).lastPathComponent
            output += "📄 \(fileName)\n"
            output += String(repeating: "─", count: 66) + "\n"

            if fileReport.functions.isEmpty {
                output += "  No functions found in this file.\n\n"
                continue
            }

            for fn in fileReport.functions {
                let name = fn.name.count > 30 ? String(fn.name.prefix(28)) + ".." : fn.name

                // Complexity rating in plain English
                let complexityLabel: String
                if fn.cyclomaticComplexity <= 3 {
                    complexityLabel = "Simple ✅"
                } else if fn.cyclomaticComplexity <= 7 {
                    complexityLabel = "Moderate ⚡"
                } else if fn.cyclomaticComplexity <= 15 {
                    complexityLabel = "Complex ⚠️"
                } else {
                    complexityLabel = "Very Complex 🚨"
                }

                // Nesting rating in plain English
                let nestingLabel: String
                if fn.maxNestingDepth <= 2 {
                    nestingLabel = "Clean ✅"
                } else if fn.maxNestingDepth <= 4 {
                    nestingLabel = "Moderate ⚡"
                } else {
                    nestingLabel = "Too Deep ⚠️"
                }

                output += "\n"
                output += "  Function: \(name)\n"
                output += "    • Complexity:    \(fn.cyclomaticComplexity) — \(complexityLabel)\n"
                output += "    • Nesting Depth: \(fn.maxNestingDepth) — \(nestingLabel)\n"
                output += "    • Length:        \(fn.lineCount) lines\n"

                if !fn.antiPatterns.isEmpty {
                    output += "    • Issues Found:  \(fn.antiPatterns.count)\n"
                } else {
                    output += "    • Issues Found:  None ✅\n"
                }
            }
            output += "\n"

            // Anti-pattern details — written in plain English
            let antiPatterns = fileReport.functions.flatMap { $0.antiPatterns }
            if !antiPatterns.isEmpty {
                output += "  🚨 Issues in this file:\n"
                for (i, pattern) in antiPatterns.enumerated() {
                    let explanation: String
                    switch pattern.type.rawValue {
                    case "force_unwrap":
                        explanation = "Using '!' to force-unwrap a value. This will crash your app if the value is nil. Use 'if let' or 'guard let' instead."
                    case "force_try":
                        explanation = "Using 'try!' to force a throwing call. This will crash if an error occurs. Wrap it in a do-catch block instead."
                    case "deep_nesting":
                        explanation = "Code is nested \(pattern.line) levels deep (too many if/for blocks inside each other). Flatten it with guard statements or extract helper functions."
                    case "long_function":
                        explanation = "This function is very long. Break it into smaller functions for readability and testability."
                    default:
                        explanation = pattern.description
                    }
                    output += "     \(i + 1). \(explanation)\n"
                }
                output += "\n"
            }
        }

        // Summary
        let s = result.summary
        output += String(repeating: "═", count: 66) + "\n"
        output += "📊 Summary\n"
        output += String(repeating: "─", count: 66) + "\n"
        output += "  Files scanned:        \(s.totalFiles)\n"
        output += "  Functions analyzed:    \(s.totalFunctions)\n"
        output += "  Average complexity:    \(String(format: "%.1f", s.averageComplexity))"

        if s.averageComplexity <= 5 {
            output += "  (Healthy ✅)\n"
        } else if s.averageComplexity <= 10 {
            output += "  (Needs attention ⚡)\n"
        } else {
            output += "  (Critical 🚨)\n"
        }

        output += "  Highest complexity:    \(s.maxComplexity) in '\(s.maxComplexityFunction)'\n"
        output += "  Total issues found:    \(s.totalAntiPatterns)"

        if s.totalAntiPatterns == 0 {
            output += "  (Clean code! 🎉)\n"
        } else {
            output += "  (Needs fixing ⚠️)\n"
        }

        output += String(repeating: "═", count: 66) + "\n"

        return output
    }
}
