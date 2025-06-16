import Foundation

struct City {
    let code: String
    let timeZoneIdentifier: String
    let displayName: String
    let emoji: String
    
    var timeZone: TimeZone {
        return TimeZone(identifier: timeZoneIdentifier) ?? TimeZone.current
    }
    
    init(code: String, timeZoneIdentifier: String, displayName: String? = nil, emoji: String? = nil) {
        self.code = code
        self.timeZoneIdentifier = timeZoneIdentifier
        self.displayName = displayName ?? code
        self.emoji = emoji ?? "🌍"
    }
}
