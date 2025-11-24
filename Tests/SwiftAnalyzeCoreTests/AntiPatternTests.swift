import XCTest
@testable import SwiftAnalyzeCore

final class AntiPatternTests: XCTestCase {
    func testForceUnwrapDetected() {
        let body = """
        func load() {
            let value = optional!
            let name = dict["key"]!
        }
        """
        let patterns = AntiPatternDetector.detect(
            in: body, startLine: 1, lineCount: 4, nestingDepth: 0
        )
        let forceUnwraps = patterns.filter { $0.type == .forceUnwrap }
        XCTAssertEqual(forceUnwraps.count, 2)
    }

    func testNotEqualNotFlagged() {
        let body = """
        func compare() {
            if a != b {
                print("different")
            }
        }
        """
        let patterns = AntiPatternDetector.detect(
            in: body, startLine: 1, lineCount: 5, nestingDepth: 1
        )
        let forceUnwraps = patterns.filter { $0.type == .forceUnwrap }
        XCTAssertEqual(forceUnwraps.count, 0)
    }

    func testForceTryDetected() {
        let body = """
        func load() {
            let data = try! fetchData()
        }
        """
        let patterns = AntiPatternDetector.detect(
            in: body, startLine: 1, lineCount: 3, nestingDepth: 0
        )
        let forceTries = patterns.filter { $0.type == .forceTry }
        XCTAssertEqual(forceTries.count, 1)
    }

    func testLongFunctionDetected() {
        let patterns = AntiPatternDetector.detect(
            in: "long body", startLine: 1, lineCount: 55, nestingDepth: 0
        )
        let longFuncs = patterns.filter { $0.type == .longFunction }
        XCTAssertEqual(longFuncs.count, 1)
    }

    func testNormalLengthNotFlagged() {
        let patterns = AntiPatternDetector.detect(
            in: "short body", startLine: 1, lineCount: 20, nestingDepth: 0
        )
        let longFuncs = patterns.filter { $0.type == .longFunction }
        XCTAssertEqual(longFuncs.count, 0)
    }

    func testDeepNestingDetected() {
        let patterns = AntiPatternDetector.detect(
            in: "deep body", startLine: 1, lineCount: 10, nestingDepth: 5
        )
        let deepNesting = patterns.filter { $0.type == .deepNesting }
        XCTAssertEqual(deepNesting.count, 1)
    }

    func testNormalNestingNotFlagged() {
        let patterns = AntiPatternDetector.detect(
            in: "normal body", startLine: 1, lineCount: 10, nestingDepth: 3
        )
        let deepNesting = patterns.filter { $0.type == .deepNesting }
        XCTAssertEqual(deepNesting.count, 0)
    }
}
