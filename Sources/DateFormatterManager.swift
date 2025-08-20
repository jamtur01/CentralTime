import Foundation

/// Centralized date formatter management to avoid creating multiple instances
/// and improve performance across the application
final class DateFormatterManager {
    
    /// Shared long format date formatter (e.g., "Mon 3:45 PM")
    static let longFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Constants.defaultLocaleIdentifier)
        formatter.dateFormat = Constants.longTimeFormat
        return formatter
    }()
    
    /// Shared short format date formatter (e.g., "3:45 PM")
    static let shortFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Constants.defaultLocaleIdentifier)
        formatter.dateFormat = Constants.shortTimeFormat
        return formatter
    }()
    
    private init() {} // Prevent instantiation
    
    /// Helper method to safely set timezone on formatter and get formatted string
    static func formatTime(for city: City, using formatter: DateFormatter, date: Date = Date()) -> String {
        if formatter.timeZone != city.timeZone {
            formatter.timeZone = city.timeZone
        }
        return formatter.string(from: date)
    }
    
    /// Convenience method for short time format
    static func formatShortTime(for city: City, date: Date = Date()) -> String {
        return formatTime(for: city, using: shortFormatter, date: date)
    }
    
    /// Convenience method for long time format
    static func formatLongTime(for city: City, date: Date = Date()) -> String {
        return formatTime(for: city, using: longFormatter, date: date)
    }
}