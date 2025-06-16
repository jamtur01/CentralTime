import Foundation

struct TimeZoneManager {
    // Major cities with their timezone identifiers
    // Swift's TimeZone.knownTimeZoneIdentifiers gives you all available timezones
    static let majorCities: [(code: String, identifier: String, city: String, country: String, emoji: String)] = [
        // North America
        ("NYC", "America/New_York", "New York", "United States", "🗽"),
        ("LAX", "America/Los_Angeles", "Los Angeles", "United States", "🌴"),
        ("CHI", "America/Chicago", "Chicago", "United States", "🏙️"),
        ("DEN", "America/Denver", "Denver", "United States", "🏔️"),
        ("SEA", "America/Los_Angeles", "Seattle", "United States", "🌲"),
        ("MIA", "America/New_York", "Miami", "United States", "🏖️"),
        ("YVR", "America/Vancouver", "Vancouver", "Canada", "🇨🇦"),
        ("YYZ", "America/Toronto", "Toronto", "Canada", "🇨🇦"),
        
        // Europe
        ("LHR", "Europe/London", "London", "United Kingdom", "🇬🇧"),
        ("CDG", "Europe/Paris", "Paris", "France", "🇫🇷"),
        ("FRA", "Europe/Berlin", "Frankfurt", "Germany", "🇩🇪"),
        ("AMS", "Europe/Amsterdam", "Amsterdam", "Netherlands", "🇳🇱"),
        ("FCO", "Europe/Rome", "Rome", "Italy", "🇮🇹"),
        ("MAD", "Europe/Madrid", "Madrid", "Spain", "🇪🇸"),
        ("SVO", "Europe/Moscow", "Moscow", "Russia", "🇷🇺"),
        
        // Asia
        ("NRT", "Asia/Tokyo", "Tokyo", "Japan", "🇯🇵"),
        ("ICN", "Asia/Seoul", "Seoul", "South Korea", "🇰🇷"),
        ("PEK", "Asia/Shanghai", "Beijing", "China", "🇨🇳"),
        ("HKG", "Asia/Hong_Kong", "Hong Kong", "Hong Kong", "🇭🇰"),
        ("SIN", "Asia/Singapore", "Singapore", "Singapore", "🇸🇬"),
        ("BOM", "Asia/Kolkata", "Mumbai", "India", "🇮🇳"),
        ("DXB", "Asia/Dubai", "Dubai", "UAE", "🇦🇪"),
        
        // Oceania
        ("SYD", "Australia/Sydney", "Sydney", "Australia", "🇦🇺"),
        ("MEL", "Australia/Melbourne", "Melbourne", "Australia", "🇦🇺"),
        ("AKL", "Pacific/Auckland", "Auckland", "New Zealand", "🇳🇿"),
        
        // Africa
        ("CAI", "Africa/Cairo", "Cairo", "Egypt", "🇪🇬"),
        ("JNB", "Africa/Johannesburg", "Johannesburg", "South Africa", "🇿🇦"),
        ("LOS", "Africa/Lagos", "Lagos", "Nigeria", "🇳🇬"),
        ("ABJ", "Africa/Abidjan", "Abidjan", "Ivory Coast", "🇨🇮"),
        
        // South America
        ("GRU", "America/Sao_Paulo", "São Paulo", "Brazil", "🇧🇷"),
        ("EZE", "America/Argentina/Buenos_Aires", "Buenos Aires", "Argentina", "🇦🇷"),
        ("SCL", "America/Santiago", "Santiago", "Chile", "🇨🇱"),
        ("LIM", "America/Lima", "Lima", "Peru", "🇵🇪")
    ]
    
    static func getAllAvailableCities() -> [City] {
        return majorCities.compactMap { cityData in
            guard TimeZone(identifier: cityData.identifier) != nil else { return nil }
            return City(
                code: cityData.code,
                timeZoneIdentifier: cityData.identifier,
                displayName: cityData.city,
                emoji: cityData.emoji
            )
        }.sorted { city1, city2 in
            // Sort by timezone offset
            let offset1 = city1.timeZone.secondsFromGMT()
            let offset2 = city2.timeZone.secondsFromGMT()
            return offset1 < offset2
        }
    }
    
    static func getDefaultCities() -> [City] {
        let defaultCodes = ["NYC", "LHR", "MEL", "LAX", "CHI"]
        return defaultCodes.compactMap { code in
            getAllAvailableCities().first { $0.code == code }
        }.sorted { city1, city2 in
            let offset1 = city1.timeZone.secondsFromGMT()
            let offset2 = city2.timeZone.secondsFromGMT()
            return offset1 < offset2
        }
    }
    
    // Get all available timezone identifiers from iOS
    static func getAllSystemTimezones() -> [String] {
        return TimeZone.knownTimeZoneIdentifiers.sorted()
    }
    
    // Create a city from any timezone identifier
    static func createCityFromTimezone(_ identifier: String) -> City? {
        guard TimeZone(identifier: identifier) != nil else { return nil }
        
        // Extract city name from identifier (e.g., "America/New_York" -> "New York")
        let components = identifier.split(separator: "/")
        let cityName = components.last?.replacingOccurrences(of: "_", with: " ") ?? identifier
        
        return City(
            code: String(cityName.prefix(3).uppercased()),
            timeZoneIdentifier: identifier,
            displayName: String(cityName),
            emoji: "🌍"
        )
    }
}