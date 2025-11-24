import Foundation

/// Data model representing a single analyzed function.
public struct FunctionInfo: Codable {
    public let name: String
    public let filePath: String
    public let startLine: Int
    public let endLine: Int
    public let lineCount: Int
    public let cyclomaticComplexity: Int
    public let maxNestingDepth: Int
    public let antiPatterns: [AntiPattern]

    public init(
        name: String,
        filePath: String,
        startLine: Int,
        endLine: Int,
        lineCount: Int,
        cyclomaticComplexity: Int,
        maxNestingDepth: Int,
        antiPatterns: [AntiPattern]
    ) {
        self.name = name
        self.filePath = filePath
        self.startLine = startLine
        self.endLine = endLine
        self.lineCount = lineCount
        self.cyclomaticComplexity = cyclomaticComplexity
        self.maxNestingDepth = maxNestingDepth
        self.antiPatterns = antiPatterns
    }
}

/// Data model for a single file's analysis results.
public struct FileReport: Codable {
    public let filePath: String
    public let functions: [FunctionInfo]

    public var totalAntiPatterns: Int {
        functions.reduce(0) { $0 + $1.antiPatterns.count }
    }

    public init(filePath: String, functions: [FunctionInfo]) {
        self.filePath = filePath
        self.functions = functions
    }
}

/// Top-level analysis result containing all file reports and a summary.
public struct AnalysisResult: Codable {
    public let files: [FileReport]
    public let summary: Summary

    public init(files: [FileReport]) {
        self.files = files
        self.summary = Summary(files: files)
    }
}

/// Summary statistics across all analyzed files.
public struct Summary: Codable {
    public let totalFiles: Int
    public let totalFunctions: Int
    public let averageComplexity: Double
    public let maxComplexity: Int
    public let maxComplexityFunction: String
    public let totalAntiPatterns: Int

    public init(files: [FileReport]) {
        let allFunctions = files.flatMap { $0.functions }
        self.totalFiles = files.count
        self.totalFunctions = allFunctions.count

        if allFunctions.isEmpty {
            self.averageComplexity = 0
            self.maxComplexity = 0
            self.maxComplexityFunction = "N/A"
        } else {
            let totalComplexity = allFunctions.reduce(0) { $0 + $1.cyclomaticComplexity }
            self.averageComplexity = Double(totalComplexity) / Double(allFunctions.count)
            let maxFunc = allFunctions.max(by: { $0.cyclomaticComplexity < $1.cyclomaticComplexity })!
            self.maxComplexity = maxFunc.cyclomaticComplexity
            self.maxComplexityFunction = maxFunc.name
        }

        self.totalAntiPatterns = files.reduce(0) { $0 + $1.totalAntiPatterns }
    }
}

/// Represents a detected anti-pattern in the code.
public struct AntiPattern: Codable {
    public let type: AntiPatternType
    public let line: Int
    public let description: String

    public init(type: AntiPatternType, line: Int, description: String) {
        self.type = type
        self.line = line
        self.description = description
    }
}

/// Types of anti-patterns detected by the analyzer.
public enum AntiPatternType: String, Codable {
    case forceUnwrap = "force_unwrap"
    case forceTry = "force_try"
    case longFunction = "long_function"
    case deepNesting = "deep_nesting"
}
