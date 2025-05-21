import Foundation

struct City {
    let code: String
    let timeZone: TimeZone
    
    init(code: String, timeZoneIdentifier: String) {
        self.code = code
        self.timeZone = TimeZone(identifier: timeZoneIdentifier) ?? TimeZone.current
    }
}
