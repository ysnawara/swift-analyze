import XCTest
@testable import SwiftAnalyzeCore

final class SwiftParserTests: XCTestCase {
    func testExtractSimpleFunction() {
        let content = """
        func greet() {
            print("Hello")
        }
        """
        let functions = SwiftParser.extractFunctions(from: content, filePath: "test.swift")
        XCTAssertEqual(functions.count, 1)
        XCTAssertEqual(functions[0].name, "greet")
    }

    func testExtractMultipleFunctions() {
        let content = """
        func first() {
            doA()
        }

        func second() {
            doB()
        }

        func third() {
            doC()
        }
        """
        let functions = SwiftParser.extractFunctions(from: content, filePath: "test.swift")
        XCTAssertEqual(functions.count, 3)
        XCTAssertEqual(functions[0].name, "first")
        XCTAssertEqual(functions[1].name, "second")
        XCTAssertEqual(functions[2].name, "third")
    }

    func testExtractFunctionWithAccessModifier() {
        let content = """
        public func publicFunc() {
            print("public")
        }

        private func privateFunc() {
            print("private")
        }

        internal static func staticFunc() {
            print("static")
        }
        """
        let functions = SwiftParser.extractFunctions(from: content, filePath: "test.swift")
        XCTAssertEqual(functions.count, 3)
        XCTAssertEqual(functions[0].name, "publicFunc")
        XCTAssertEqual(functions[1].name, "privateFunc")
        XCTAssertEqual(functions[2].name, "staticFunc")
    }

    func testExtractInit() {
        let content = """
        init(name: String) {
            self.name = name
        }
        """
        let functions = SwiftParser.extractFunctions(from: content, filePath: "test.swift")
        XCTAssertEqual(functions.count, 1)
        XCTAssertEqual(functions[0].name, "init")
    }

    func testLineNumbers() {
        let content = """
        // Comment
        func test() {
            let a = 1
            let b = 2
        }
        """
        let functions = SwiftParser.extractFunctions(from: content, filePath: "test.swift")
        XCTAssertEqual(functions.count, 1)
        XCTAssertEqual(functions[0].startLine, 2) // 1-indexed
    }

    func testSkipsComments() {
        let content = """
        // func notAFunction() { }
        func realFunction() {
            doStuff()
        }
        """
        let functions = SwiftParser.extractFunctions(from: content, filePath: "test.swift")
        XCTAssertEqual(functions.count, 1)
        XCTAssertEqual(functions[0].name, "realFunction")
    }
}
