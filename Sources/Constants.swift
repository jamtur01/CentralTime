import Foundation
import CoreGraphics

enum Constants {
    // Timer intervals
    static let cityRotationInterval: TimeInterval = 3.0
    static let timerTolerance: TimeInterval = 0.1
    
    // Time calculations
    static let secondsPerHour: TimeInterval = 3600
    
    // UI dimensions
    static let popoverWidth: CGFloat = 320
    static let popoverHeight: CGFloat = 400
    static let settingsWindowWidth: CGFloat = 500
    static let settingsWindowHeight: CGFloat = 600
    
    // UI layout
    static let defaultPadding: CGFloat = 16
    static let itemSpacing: CGFloat = 12
    static let compactSpacing: CGFloat = 6
    
    // Default values
    static let defaultCityCodes = ["NYC", "LHR", "MEL", "LAX", "CHI"]
    static let defaultMenuBarTitle = "🕐 CT"
    
    // Animation
    static let animationDuration: TimeInterval = 0.2
    
    // Performance
    static let maxCitiesToDisplay = 50
    
    // Date formatting
    static let shortTimeFormat = "h:mm a"
    static let longTimeFormat = "EEE h:mm a"
    static let defaultLocaleIdentifier = "en_US"
}