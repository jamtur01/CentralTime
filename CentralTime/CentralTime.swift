import Cocoa

// City model
struct City {
    let code: String
    let timeZoneIdentifier: String
    
    var timeZone: TimeZone {
        return TimeZone(identifier: timeZoneIdentifier) ?? TimeZone.current
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var timer: Timer?
    var currentCityIndex = 0
    
    // Cities configuration - same as the original Hammerspoon spoon
    let cities = [
        City(code: "ORD", timeZoneIdentifier: "America/Chicago"),
        City(code: "SFO", timeZoneIdentifier: "America/Los_Angeles"),
        City(code: "BLR", timeZoneIdentifier: "Asia/Kolkata"),
        City(code: "MEL", timeZoneIdentifier: "Australia/Melbourne"),
        City(code: "LON", timeZoneIdentifier: "Europe/London")
    ]
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // Set initial text
        statusItem?.button?.title = "CentralTime"
        
        // Create a simple menu
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        statusItem?.menu = menu
        
        // Start timer to update times
        startTimer()
        
        // Log to console to confirm app is running
        print("CentralTime app launched successfully")
    }
    
    func startTimer() {
        // Clear any existing timer
        timer?.invalidate()
        
        // Create a new timer that fires every 3 seconds
        timer = Timer.scheduledTimer(timeInterval: 3.0, 
                                     target: self, 
                                     selector: #selector(updateTime), 
                                     userInfo: nil, 
                                     repeats: true)
        
        // Ensure timer works even when showing menu
        RunLoop.current.add(timer!, forMode: .common)
        
        // Update immediately
        updateTime()
    }
    
    @objc func updateTime() {
        let city = cities[currentCityIndex]
        let timeString = getTimeString(for: city)
        statusItem?.button?.title = timeString
        
        // Move to next city
        currentCityIndex = (currentCityIndex + 1) % cities.count
    }
    
    func getTimeString(for city: City) -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.timeZone = city.timeZone
        
        // Explicitly use 12-hour format with AM/PM
        formatter.dateFormat = "EEE h:mm a"
        
        // Force 12-hour locale (to ensure AM/PM display)
        formatter.locale = Locale(identifier: "en_US")
        
        // Get the formatted time string
        let formattedTime = formatter.string(from: date)
        return "\(city.code) \(formattedTime)"
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
}

// Create the application
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// Set activation policy for menu bar app
app.setActivationPolicy(.accessory)

// Run the application
app.run()
