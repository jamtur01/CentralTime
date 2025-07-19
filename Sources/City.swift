import Foundation

struct City: Equatable, Hashable {
    let code: String
    let timeZoneIdentifier: String
    let displayName: String
    let emoji: String
    
    private var _timeZone: TimeZone?
    
    var timeZone: TimeZone {
        if let cached = _timeZone {
            return cached
        }
        return TimeZone(identifier: timeZoneIdentifier) ?? TimeZone.current
    }
    
    init(code: String, timeZoneIdentifier: String, displayName: String? = nil, emoji: String? = nil) {
        self.code = code
        self.timeZoneIdentifier = timeZoneIdentifier
        self.displayName = displayName ?? code
        self.emoji = emoji ?? "🌍"
        self._timeZone = TimeZone(identifier: timeZoneIdentifier)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(timeZoneIdentifier)
    }
    
    static func == (lhs: City, rhs: City) -> Bool {
        return lhs.timeZoneIdentifier == rhs.timeZoneIdentifier
    }
}
