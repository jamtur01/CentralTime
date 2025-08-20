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
}