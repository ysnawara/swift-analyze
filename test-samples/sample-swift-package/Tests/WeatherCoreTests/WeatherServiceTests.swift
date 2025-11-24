import XCTest
@testable import WeatherCore

final class WeatherServiceTests: XCTestCase {
    func testFetchWeatherReturnsData() async throws {
        let service = WeatherService(apiKey: "test-key")
        let weather = try await service.fetchWeather(for: "London")
        XCTAssertEqual(weather.city, "London")
    }

    func testFetchWeatherEmptyCityThrows() async {
        let service = WeatherService(apiKey: "test-key")
        do {
            _ = try await service.fetchWeather(for: "")
            XCTFail("Expected error for empty city")
        } catch {
            // Expected
        }
    }

    func testTemperatureConversion() {
        let data = WeatherData(city: "Test", temperature: 0, conditions: "Sunny", humidity: 50, windSpeed: 10)
        XCTAssertEqual(data.temperatureFahrenheit, 32.0, accuracy: 0.1)
    }

    func testForecastDaysValidation() async {
        let service = WeatherService(apiKey: "test-key")
        do {
            _ = try await service.fetchForecast(for: "Paris", days: 0)
            XCTFail("Expected error for 0 days")
        } catch {
            // Expected
        }
    }
}

final class CacheManagerTests: XCTestCase {
    func testStoreAndRetrieve() {
        let cache = CacheManager()
        cache.store(key: "test", data: "value")
        let result = cache.retrieve(key: "test")
        XCTAssertNotNil(result)
    }

    func testRetrieveNonExistent() {
        let cache = CacheManager()
        let result = cache.retrieve(key: "missing")
        XCTAssertNil(result)
    }

    func testClearAll() {
        let cache = CacheManager()
        cache.store(key: "a", data: 1)
        cache.store(key: "b", data: 2)
        cache.clearAll()
        XCTAssertNil(cache.retrieve(key: "a"))
        XCTAssertNil(cache.retrieve(key: "b"))
    }
}
