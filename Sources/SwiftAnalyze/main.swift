import ArgumentParser
import Foundation
import SwiftAnalyzeCore

/// swift-analyze: A cross-platform Swift code analysis tool.
///
/// Analyzes Swift source files for cyclomatic complexity, nesting depth,
/// function length, and common anti-patterns. Outputs results as text
/// or JSON for CI/CD integration.
@main
struct SwiftAnalyzeCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "swift-analyze",
        abstract: "Analyze Swift source files for complexity and anti-patterns",
        version: "0.1.0"
    )

    @Argument(help: "Path to a Swift file or directory to analyze")
    var path: String

    @Flag(name: .shortAndLong, help: "Recursively analyze directories")
    var recursive: Bool = false

    @Option(name: .long, help: "Output format: text or json")
    var format: OutputFormat = .text

    @Option(name: .long, help: "Maximum allowed cyclomatic complexity per function")
    var maxComplexity: Int?

    @Option(name: .long, help: "Maximum allowed nesting depth per function")
    var maxNesting: Int?

    @Option(name: .long, help: "Maximum allowed function length (lines)")
    var maxLength: Int?

    func run() throws {
        let analyzer = Analyzer()
        let files = FileScanner.findSwiftFiles(at: path, recursive: recursive)

        if files.isEmpty {
            print("No Swift files found at: \(path)")
            throw ExitCode.failure
        }

        let result = analyzer.analyze(files: files)

        // Format and print output
        switch format {
        case .text:
            print(TextFormatter.format(result))
        case .json:
            print(JSONFormatter.format(result))
        }

        // Check thresholds
        if let maxComplexity = maxComplexity {
            let violations = result.files.flatMap { $0.functions }
                .filter { $0.cyclomaticComplexity > maxComplexity }
            if !violations.isEmpty {
                for v in violations {
                    printError("Complexity \(v.cyclomaticComplexity) exceeds threshold \(maxComplexity): \(v.name) in \(v.filePath):\(v.startLine)")
                }
                throw ExitCode(1)
            }
        }

        if let maxNesting = maxNesting {
            let violations = result.files.flatMap { $0.functions }
                .filter { $0.maxNestingDepth > maxNesting }
            if !violations.isEmpty {
                for v in violations {
                    printError("Nesting depth \(v.maxNestingDepth) exceeds threshold \(maxNesting): \(v.name) in \(v.filePath):\(v.startLine)")
                }
                throw ExitCode(1)
            }
        }

        if let maxLength = maxLength {
            let violations = result.files.flatMap { $0.functions }
                .filter { $0.lineCount > maxLength }
            if !violations.isEmpty {
                for v in violations {
                    printError("Function length \(v.lineCount) exceeds threshold \(maxLength): \(v.name) in \(v.filePath):\(v.startLine)")
                }
                throw ExitCode(1)
            }
        }
    }

    private func printError(_ message: String) {
        var stderr = FileHandle.standardError
        stderr.write(Data("warning: \(message)\n".utf8))
    }
}

/// Output format options for the CLI.
enum OutputFormat: String, ExpressibleByArgument {
    case text
    case json
}

/// Make FileHandle work as a TextOutputStream for stderr.
extension FileHandle: @retroactive TextOutputStream {
    public func write(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.write(data)
        }
    }
}
