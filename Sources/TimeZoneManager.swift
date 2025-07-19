import Foundation

struct TimeZoneManager {
    private static var _sortedCities: [City]?
    private static let sortedCitiesQueue = DispatchQueue(label: "com.centraltime.sortedCities", attributes: .concurrent)
    
    static func getAllAvailableCities() -> [City] {
        return sortedCitiesQueue.sync {
            if let cached = _sortedCities {
                return cached
            }
            
            let sorted = TimeZoneData.allTimezones.sorted { city1, city2 in
                let offset1 = city1.timeZone.secondsFromGMT()
                let offset2 = city2.timeZone.secondsFromGMT()
                return offset1 < offset2
            }
            
            sortedCitiesQueue.async(flags: .barrier) {
                _sortedCities = sorted
            }
            
            return sorted
        }
    }
    
    static func getDefaultCities() -> [City] {
        let defaultCodes = Constants.defaultCityCodes
        let allCities = getAllAvailableCities()
        let defaultCities = defaultCodes.compactMap { code in
            allCities.first { $0.code == code }
        }
        return sortCitiesByTimezone(defaultCities)
    }
    
    static func sortCitiesByTimezone(_ cities: [City]) -> [City] {
        return cities.sorted { city1, city2 in
            let offset1 = city1.timeZone.secondsFromGMT()
            let offset2 = city2.timeZone.secondsFromGMT()
            return offset1 < offset2
        }
    }
    
    static func createCityFromTimezone(_ identifier: String) -> City? {
        guard TimeZone(identifier: identifier) != nil else { return nil }
        
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