import Foundation

/// Formats analysis results as structured JSON for CI/CD integration.
public enum JSONFormatter {
    public static func format(_ result: AnalysisResult) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        do {
            let data = try encoder.encode(result)
            return String(data: data, encoding: .utf8) ?? "{}"
        } catch {
            return "{ \"error\": \"Failed to encode results: \(error.localizedDescription)\" }"
        }
    }
}
