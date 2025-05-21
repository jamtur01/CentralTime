import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var timer: Timer?
    private var updateInterval: TimeInterval = 3.0
    private var currentCityIndex = 0
    
    private let cities: [City] = [
        City(code: "ORD", timeZoneIdentifier: "America/Chicago"),
        City(code: "SFO", timeZoneIdentifier: "America/Los_Angeles"),
        City(code: "BLR", timeZoneIdentifier: "Asia/Kolkata"),
        City(code: "MEL", timeZoneIdentifier: "Australia/Melbourne"),
        City(code: "LON", timeZoneIdentifier: "Europe/London")
    ]
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupMenuBar()
        startTimer()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        stopTimer()
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // Make sure we have a button to display text
        if let button = statusItem.button {
            button.title = "CentralTime"
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
        statusItem.menu = menu
        
        // Initial update
        updateTime()
    }
    
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(timeInterval: updateInterval, 
                                     target: self, 
                                     selector: #selector(timerFired), 
                                     userInfo: nil, 
                                     repeats: true)
        timer?.tolerance = 0.1 // Add some tolerance for better power efficiency
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func timerFired() {
        updateTime()
    }
    
    private func updateTime() {
        let city = cities[currentCityIndex]
        let timeString = getTimeString(for: city)
        
        // Update the button title safely
        if let button = statusItem.button {
            button.title = timeString
        }
        
        // Move to next city
        currentCityIndex = (currentCityIndex + 1) % cities.count
    }
    
    private func getTimeString(for city: City) -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.timeZone = city.timeZone
        formatter.dateFormat = "EEE h:mm a" // Format as "Day H:MM AM/PM"
        
        let formattedTime = formatter.string(from: date)
        return "\(city.code) \(formattedTime)"
    }
    
    @objc private func quitApp() {
        NSApplication.shared.terminate(self)
    }
}
