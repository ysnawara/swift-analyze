import XCTest
@testable import SwiftAnalyzeCore

final class FormatterTests: XCTestCase {
    func testJSONOutputIsValid() {
        let result = makeTestResult()
        let json = JSONFormatter.format(result)

        // Verify it's valid JSON
        let data = json.data(using: .utf8)!
        XCTAssertNoThrow(try JSONSerialization.jsonObject(with: data))
    }

    func testJSONContainsExpectedFields() {
        let result = makeTestResult()
        let json = JSONFormatter.format(result)

        XCTAssertTrue(json.contains("\"files\""))
        XCTAssertTrue(json.contains("\"summary\""))
        XCTAssertTrue(json.contains("\"totalFiles\""))
        XCTAssertTrue(json.contains("\"totalFunctions\""))
        XCTAssertTrue(json.contains("\"averageComplexity\""))
    }

    func testTextOutputContainsHeader() {
        let result = makeTestResult()
        let text = TextFormatter.format(result)

        XCTAssertTrue(text.contains("Swift Code Analysis"))
        XCTAssertTrue(text.contains("Summary"))
    }

    func testTextOutputContainsFunctionName() {
        let result = makeTestResult()
        let text = TextFormatter.format(result)

        XCTAssertTrue(text.contains("testFunc"))
    }

    func testEmptyResultFormatting() {
        let result = AnalysisResult(files: [])
        let json = JSONFormatter.format(result)
        let text = TextFormatter.format(result)

        XCTAssertTrue(json.contains("\"totalFiles\" : 0"))
        XCTAssertTrue(text.contains("Summary"))
    }

    // MARK: - Helpers

    private func makeTestResult() -> AnalysisResult {
        let func1 = FunctionInfo(
            name: "testFunc",
            filePath: "test.swift",
            startLine: 1,
            endLine: 10,
            lineCount: 10,
            cyclomaticComplexity: 3,
            maxNestingDepth: 2,
            antiPatterns: []
        )
        let report = FileReport(filePath: "test.swift", functions: [func1])
        return AnalysisResult(files: [report])
    }
}
