# swift-analyze

A cross-platform Swift CLI tool that analyzes source files for cyclomatic complexity, nesting depth, function length, and common anti-patterns. Outputs results as human-readable text or structured JSON for CI/CD integration.

## Features

- **Cyclomatic Complexity** — counts decision points (`if`, `guard`, `switch case`, `for`, `while`, `catch`, `&&`, `||`, `??`) per function
- **Nesting Depth** — tracks maximum brace nesting level per function
- **Function Length** — lines of code per function
- **Anti-Pattern Detection** — force unwraps (`!`), force try (`try!`), long functions (>50 lines), deep nesting (>4 levels)
- **Multiple Output Formats** — human-readable text tables or JSON for tooling integration
- **Threshold Enforcement** — exit code 1 if any metric exceeds configurable thresholds (for CI gating)
- **Recursive Analysis** — scan single files or entire directory trees
- **Cross-Platform** — tested on macOS, Linux, and Windows via GitHub Actions

## Installation

```bash
git clone https://github.com/ysnawara/swift-analyze.git
cd swift-analyze
swift build -c release
```

The binary will be at `.build/release/swift-analyze`.

## Usage

```bash
# Analyze a single file
swift-analyze Sources/MyFile.swift

# Analyze a directory recursively
swift-analyze Sources/ --recursive

# JSON output for CI/CD pipelines
swift-analyze Sources/ --format json --recursive

# Enforce thresholds (exit code 1 on violation)
swift-analyze Sources/ --max-complexity 10 --max-nesting 4 --max-length 50

# Pipe JSON to a file for reporting
swift-analyze . --recursive --format json > analysis-report.json
```

## Example Output

### Text Format

```
╔══════════════════════════════════════════════════════════════╗
║                    Swift Code Analysis                       ║
╚══════════════════════════════════════════════════════════════╝

📄 ViewController.swift
────────────────────────────────────────────────────────────────
  Function                            CC  Nest Lines  Anti
  ───────────────────────────────────────────────────────────
  viewDidLoad                          3     2    15     0
  handleTap                            5     3    28     0
  processData                          8     4    42     1   ⚠️

  ⚠️  Anti-patterns:
     L45: [force_unwrap] Force unwrap detected — consider using optional binding

════════════════════════════════════════════════════════════════
📊 Summary
────────────────────────────────────────────────────────────────
  Files analyzed:     1
  Functions found:    3
  Avg complexity:     5.3
  Max complexity:     8 (processData)
  Total anti-patterns: 1
```

### JSON Format

```json
{
  "files": [
    {
      "filePath": "Sources/Example.swift",
      "functions": [
        {
          "name": "processData",
          "cyclomaticComplexity": 8,
          "maxNestingDepth": 4,
          "lineCount": 42,
          "antiPatterns": [
            {
              "type": "force_unwrap",
              "line": 45,
              "description": "Force unwrap detected"
            }
          ]
        }
      ]
    }
  ],
  "summary": {
    "totalFiles": 1,
    "totalFunctions": 1,
    "averageComplexity": 8.0,
    "maxComplexity": 8,
    "totalAntiPatterns": 1
  }
}
```

## Architecture

```
Sources/
├── SwiftAnalyze/           # CLI executable
│   └── main.swift          # ArgumentParser entry point
└── SwiftAnalyzeCore/       # Core library (testable)
    ├── Analyzer.swift       # Top-level orchestrator
    ├── FileScanner.swift    # Recursive .swift file discovery
    ├── SwiftParser.swift    # Function extraction via regex + brace tracking
    ├── Models.swift         # Data types (FunctionInfo, FileReport, etc.)
    ├── AntiPatterns.swift   # Anti-pattern detection
    ├── Metrics/
    │   ├── CyclomaticComplexity.swift
    │   └── NestingDepth.swift
    └── Formatters/
        ├── TextFormatter.swift
        └── JSONFormatter.swift
```

### Design Decisions

- **Regex-based parsing** instead of `swift-syntax` — keeps the tool lightweight (~100KB binary vs ~200MB with swift-syntax) and maximizes cross-platform compatibility. For the metrics computed (counting keywords and brace depth), regex provides correct results for well-formed Swift code.
- **Separate Core library** — all analysis logic is in `SwiftAnalyzeCore` so it can be tested independently and potentially reused as a library.
- **Apple's ArgumentParser** — follows the standard Swift CLI pattern for argument/flag handling.

## Testing

```bash
swift test
```

Tests cover:
- Cyclomatic complexity calculation (10 test cases)
- Nesting depth calculation (6 test cases)
- Anti-pattern detection (7 test cases)
- Swift parser function extraction (6 test cases)
- Output formatting — JSON and text (5 test cases)

## CI/CD

GitHub Actions runs `swift build` and `swift test` on every push across three platforms:
- macOS (latest)
- Ubuntu (latest)
- Windows (latest)

## Requirements

- Swift 5.9 or later
- No external dependencies beyond [swift-argument-parser](https://github.com/apple/swift-argument-parser)

## License

MIT
