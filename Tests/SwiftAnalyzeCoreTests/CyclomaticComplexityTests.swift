import XCTest
@testable import SwiftAnalyzeCore

final class CyclomaticComplexityTests: XCTestCase {
    func testSimpleFunction() {
        let body = """
        func greet() {
            print("Hello")
        }
        """
        XCTAssertEqual(CyclomaticComplexity.calculate(for: body), 1)
    }

    func testSingleIf() {
        let body = """
        func check(value: Int) {
            if value > 0 {
                print("positive")
            }
        }
        """
        XCTAssertEqual(CyclomaticComplexity.calculate(for: body), 2)
    }

    func testIfElseIf() {
        let body = """
        func classify(value: Int) {
            if value > 0 {
                print("positive")
            } else if value < 0 {
                print("negative")
            } else {
                print("zero")
            }
        }
        """
        // Base(1) + if(1) + if(1) = 3
        XCTAssertEqual(CyclomaticComplexity.calculate(for: body), 3)
    }

    func testGuardStatement() {
        let body = """
        func process(value: Int?) {
            guard let v = value else {
                return
            }
            print(v)
        }
        """
        XCTAssertEqual(CyclomaticComplexity.calculate(for: body), 2)
    }

    func testSwitchCases() {
        let body = """
        func handle(state: State) {
            switch state {
            case .idle:
                break
            case .loading:
                showSpinner()
            case .loaded:
                showContent()
            case .error:
                showError()
            }
        }
        """
        // Base(1) + 4 cases = 5
        XCTAssertEqual(CyclomaticComplexity.calculate(for: body), 5)
    }

    func testForLoop() {
        let body = """
        func sum(values: [Int]) -> Int {
            var total = 0
            for v in values {
                total += v
            }
            return total
        }
        """
        XCTAssertEqual(CyclomaticComplexity.calculate(for: body), 2)
    }

    func testBooleanOperators() {
        let body = """
        func validate(a: Bool, b: Bool, c: Bool) {
            if a && b || c {
                process()
            }
        }
        """
        // Base(1) + if(1) + &&(1) + ||(1) = 4
        XCTAssertEqual(CyclomaticComplexity.calculate(for: body), 4)
    }

    func testNilCoalescing() {
        let body = """
        func getValue(a: String?, b: String?) -> String {
            return a ?? b ?? "default"
        }
        """
        // Base(1) + ??(1) + ??(1) = 3
        XCTAssertEqual(CyclomaticComplexity.calculate(for: body), 3)
    }

    func testCatchBlock() {
        let body = """
        func load() {
            do {
                try fetchData()
            } catch {
                handleError()
            }
        }
        """
        XCTAssertEqual(CyclomaticComplexity.calculate(for: body), 2)
    }

    func testComplexFunction() {
        let body = """
        func process(items: [Item]) {
            guard !items.isEmpty else { return }
            for item in items {
                if item.isValid && item.isEnabled {
                    switch item.type {
                    case .typeA:
                        handleA()
                    case .typeB:
                        handleB()
                    }
                } else if item.isFallback {
                    handleFallback()
                }
            }
        }
        """
        // Base(1) + guard(1) + for(1) + if(1) + &&(1) + case(1) + case(1) + if(1) = 8
        XCTAssertEqual(CyclomaticComplexity.calculate(for: body), 8)
    }
}
