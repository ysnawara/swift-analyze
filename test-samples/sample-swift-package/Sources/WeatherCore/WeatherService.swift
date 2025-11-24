import Foundation

/// A service that fetches weather data from an API.
public class WeatherService {
    private let apiKey: String
    private let baseURL: String

    public init(apiKey: String, baseURL: String = "https://api.weather.example.com") {
        self.apiKey = apiKey
        self.baseURL = baseURL
    }

    /// Fetches the current weather for a given city.
    public func fetchWeather(for city: String) async throws -> WeatherData {
        guard !city.isEmpty else {
            throw WeatherError.invalidCity
        }

        let url = "\(baseURL)/current?city=\(city)&key=\(apiKey)"

        // Simulate network call
        let temperature = Double.random(in: -10...40)
        let conditions = ["Sunny", "Cloudy", "Rainy", "Snowy", "Windy"].randomElement()!

        return WeatherData(
            city: city,
            temperature: temperature,
            conditions: conditions,
            humidity: Int.random(in: 20...95),
            windSpeed: Double.random(in: 0...50)
        )
    }

    /// Fetches forecast for the next N days.
    public func fetchForecast(for city: String, days: Int) async throws -> [WeatherData] {
        guard days > 0 && days <= 14 else {
            throw WeatherError.invalidDaysRange
        }

        var forecast: [WeatherData] = []
        for _ in 0..<days {
            let data = try await fetchWeather(for: city)
            forecast.append(data)
        }
        return forecast
    }
}

/// Represents weather data for a specific location.
public struct WeatherData: Codable {
    public let city: String
    public let temperature: Double
    public let conditions: String
    public let humidity: Int
    public let windSpeed: Double

    public var temperatureFahrenheit: Double {
        return temperature * 9.0 / 5.0 + 32.0
    }

    public var description: String {
        return "\(city): \(String(format: "%.1f", temperature))°C (\(conditions)), Humidity: \(humidity)%"
    }
}

/// Weather-related errors.
public enum WeatherError: Error, CustomStringConvertible {
    case invalidCity
    case invalidDaysRange
    case networkError(String)
    case decodingError

    public var description: String {
        switch self {
        case .invalidCity:
            return "City name cannot be empty"
        case .invalidDaysRange:
            return "Days must be between 1 and 14"
        case .networkError(let msg):
            return "Network error: \(msg)"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}
