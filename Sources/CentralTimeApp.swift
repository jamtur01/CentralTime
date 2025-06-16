import SwiftUI

@main
struct CentralTimeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

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

class StatusBarController {
    private var statusBar: NSStatusBar
    private var statusItem: NSStatusItem
    private var popover: NSPopover
    private var appState = AppState()
    var settingsWindow: NSWindow?
    
    init() {
        statusBar = NSStatusBar.system
        statusItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        popover = NSPopover()
        
        setupPopover()
        setupStatusItem()
        startTimer()
    }
    
    func setup() {
        updateStatusItemTitle()
    }
    
    private func setupPopover() {
        popover.contentSize = NSSize(width: 320, height: 400)
        popover.behavior = .applicationDefined
        popover.animates = true
        popover.contentViewController = NSHostingController(rootView: PopoverView(appState: appState, statusBarController: self))
    }
    
    private func setupStatusItem() {
        statusItem.button?.action = #selector(togglePopover(_:))
        statusItem.button?.target = self
        updateStatusItemTitle()
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            self.updateStatusItemTitle()
        }
    }
    
    private func updateStatusItemTitle() {
        DispatchQueue.main.async {
            if let currentCity = self.appState.currentDisplayCity {
                let timeString = self.appState.currentTimeString
                self.statusItem.button?.title = "\(currentCity.emoji) \(currentCity.code) \(timeString)"
            } else {
                self.statusItem.button?.title = "🕐 CT"
            }
        }
    }
    
@objc private func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            hidePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
    
    private func showPopover(sender: AnyObject?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    
    func hidePopover(sender: AnyObject?) {
        popover.performClose(sender)
    }
    
    func openSettingsWindow() {
        // If settings window is already open, just bring it to front
        if let existingWindow = settingsWindow, existingWindow.isVisible {
            existingWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        // Close existing window if open
        settingsWindow?.close()
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 600),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "City Selection"
        window.minSize = NSSize(width: 500, height: 600)
        window.setContentSize(NSSize(width: 500, height: 600))
        
        // Create a custom delegate to prevent app termination
        let delegate = SettingsWindowDelegate(statusBarController: self)
        window.delegate = delegate
        
        let citySelectionView = CitySelectionView(onClose: {
            DispatchQueue.main.async {
                self.settingsWindow = nil
                window.orderOut(nil)
            }
        }).environmentObject(appState)
        
        window.contentViewController = NSHostingController(rootView: citySelectionView)
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        settingsWindow = window
    }
}

class SettingsWindowDelegate: NSObject, NSWindowDelegate {
    weak var statusBarController: StatusBarController?
    
    init(statusBarController: StatusBarController? = nil) {
        self.statusBarController = statusBarController
        super.init()
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        return true // Allow window to close
    }
    
    func windowWillClose(_ notification: Notification) {
        // Clear the reference when window closes
        statusBarController?.settingsWindow = nil
    }
}

struct PopoverView: View {
    @ObservedObject var appState: AppState
    weak var statusBarController: StatusBarController?
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Text("🌍 World Clock")
                    .font(.headline)
                Spacer()
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            
            // Cities
            VStack(spacing: 6) {
                ForEach(appState.selectedCities, id: \.timeZoneIdentifier) { city in
                    HStack {
                        Text(city.emoji)
                            .frame(width: 20)
                        Text(city.code)
                            .font(.monospaced(.body)())
                            .frame(width: 40, alignment: .leading)
                        Text(city.displayName)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(appState.getTimeString(for: city, useSliderTime: true))
                            .font(.monospaced(.caption)())
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if appState.timeSliderOffset != 0 {
                Text("Time offset: \(Int(appState.timeSliderOffset / 3600))h")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            Divider()
            
            // Time Controls
            HStack {
                Button("← Hour") { appState.previousHour() }
                Button("Reset") { appState.resetTime() }
                Button("Hour →") { appState.nextHour() }
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            
            // Settings
            Button("⚙️ Settings") {
                statusBarController?.openSettingsWindow()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(16)
        .frame(width: 300)
    }
}