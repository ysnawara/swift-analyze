import Foundation

/// Top-level orchestrator that coordinates file parsing and metric computation.
public class Analyzer {
    public init() {}

    /// Analyzes a list of Swift source files and returns a comprehensive report.
    public func analyze(files: [String]) -> AnalysisResult {
        var reports: [FileReport] = []

        for filePath in files {
            guard let content = try? String(contentsOfFile: filePath, encoding: .utf8) else {
                continue
            }

            let functions = SwiftParser.extractFunctions(from: content, filePath: filePath)
            var analyzedFunctions: [FunctionInfo] = []

            for funcInfo in functions {
                let complexity = CyclomaticComplexity.calculate(for: funcInfo.body)
                let nesting = NestingDepth.calculate(for: funcInfo.body)
                let lineCount = funcInfo.endLine - funcInfo.startLine + 1
                let antiPatterns = AntiPatternDetector.detect(
                    in: funcInfo.body,
                    startLine: funcInfo.startLine,
                    lineCount: lineCount,
                    nestingDepth: nesting
                )

                analyzedFunctions.append(FunctionInfo(
                    name: funcInfo.name,
                    filePath: filePath,
                    startLine: funcInfo.startLine,
                    endLine: funcInfo.endLine,
                    lineCount: lineCount,
                    cyclomaticComplexity: complexity,
                    maxNestingDepth: nesting,
                    antiPatterns: antiPatterns
                ))
            }

            reports.append(FileReport(filePath: filePath, functions: analyzedFunctions))
        }

        return AnalysisResult(files: reports)
    }
}
