import Foundation

struct City {
    let code: String
    let timeZoneIdentifier: String
    
    var timeZone: TimeZone {
        return TimeZone(identifier: timeZoneIdentifier) ?? TimeZone.current
    }
}
