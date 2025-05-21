import Cocoa

// Create the application
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// Set activation policy for menu bar app
app.setActivationPolicy(.accessory)

// Run the application
app.run()
