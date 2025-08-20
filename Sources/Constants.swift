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
    
    // Default values
    static let defaultCityCodes = ["NYC", "LHR", "MEL", "LAX", "CHI"]
    static let defaultMenuBarTitle = "🕐 CT"
    
    // Performance
    static let maxCitiesToDisplay = 50
    
    // Date formatting
    static let shortTimeFormat = "h:mm a"
    static let longTimeFormat = "EEE h:mm a"
    static let defaultLocaleIdentifier = "en_US"
    
    // Window titles
    static let citySelectionWindowTitle = "City Selection"
    static let worldClockTitle = "🌍 World Clock"
    
    // Button labels
    static let quitButtonLabel = "Quit"
    static let settingsButtonLabel = "⚙️ Settings"
    static let cancelButtonLabel = "Cancel"
    static let saveButtonLabel = "Save"
    static let resetButtonLabel = "Reset"
}