import Cocoa
import SwiftUI

class MenuBarController: ObservableObject {
    private var statusItem: NSStatusItem?
    private var appState: AppState
    
    init(appState: AppState) {
        self.appState = appState
        setupStatusItem()
        updateMenuBarText()
        
        // Start timer to update menu bar text
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            self.updateMenuBarText()
        }
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.title = "🕐 CT"
    }
    
    private func updateMenuBarText() {
        DispatchQueue.main.async {
            if let currentCity = self.appState.currentDisplayCity {
                let timeString = self.appState.currentTimeString
                self.statusItem?.button?.title = "\(currentCity.emoji) \(currentCity.code) \(timeString)"
            } else {
                self.statusItem?.button?.title = "🕐 CT"
            }
        }
    }
    
    func setMenu(_ menu: NSMenu) {
        statusItem?.menu = menu
    }
}