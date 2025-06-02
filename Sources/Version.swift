// Version information for CentralTime

import Foundation

public struct Version {
    /// The current version of the application (SemVer format)
    public static let version = "1.0.0"
    
    /// The current build number
    public static let build = "1"
    
    /// Returns the full version string (version + build)
    public static var fullVersion: String {
        return "\(version) (\(build))"
    }
}