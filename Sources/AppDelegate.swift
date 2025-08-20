import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    static private(set) var instance: AppDelegate!
    lazy var statusBarController = StatusBarController()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.instance = self
        
        // Hide from dock
        NSApp.setActivationPolicy(.accessory)
        
        // Setup status bar
        statusBarController.setup()
    }
}