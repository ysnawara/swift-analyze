import XCTest
@testable import SwiftAnalyzeCore

final class NestingDepthTests: XCTestCase {
    func testFlatFunction() {
        let body = """
        func flat() {
            let a = 1
            let b = 2
            print(a + b)
        }
        """
        XCTAssertEqual(NestingDepth.calculate(for: body), 0)
    }

    func testSingleLevel() {
        let body = """
        func oneLevel() {
            if true {
                print("nested")
            }
        }
        """
        XCTAssertEqual(NestingDepth.calculate(for: body), 1)
    }

    func testDoubleNesting() {
        let body = """
        func twoLevels() {
            if true {
                for i in 0..<10 {
                    print(i)
                }
            }
        }
        """
        XCTAssertEqual(NestingDepth.calculate(for: body), 2)
    }

    func testTripleNesting() {
        let body = """
        func threeLevels() {
            if true {
                for i in items {
                    if i.isValid {
                        process(i)
                    }
                }
            }
        }
        """
        XCTAssertEqual(NestingDepth.calculate(for: body), 3)
    }

    func testDeeplyNested() {
        let body = """
        func deep() {
            if a {
                if b {
                    if c {
                        if d {
                            if e {
                                print("deep")
                            }
                        }
                    }
                }
            }
        }
        """
        XCTAssertEqual(NestingDepth.calculate(for: body), 5)
    }

    func testSequentialNotNested() {
        let body = """
        func sequential() {
            if a {
                doA()
            }
            if b {
                doB()
            }
            if c {
                doC()
            }
        }
        """
        // Sequential ifs, not nested — max depth is 1
        XCTAssertEqual(NestingDepth.calculate(for: body), 1)
    }
}
