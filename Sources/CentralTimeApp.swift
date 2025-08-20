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

import Combine

final class StatusBarController {
    private var statusBar: NSStatusBar
    private var statusItem: NSStatusItem
    private var popover: NSPopover
    private let appState = AppState()
    private var cancellables = Set<AnyCancellable>()
    private var updateTimer: Timer?
    weak var settingsWindow: NSWindow?
    
    init() {
        statusBar = NSStatusBar.system
        statusItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        popover = NSPopover()
        
        setupPopover()
        setupStatusItem()
    }
    
    func setup() {
        Task { @MainActor [weak self] in
            self?.updateStatusItemTitle()
        }
        startUpdateTimer()
    }
    
    deinit {
        updateTimer?.invalidate()
        cancellables.removeAll()
    }
    
    func cleanup() {
        updateTimer?.invalidate()
        updateTimer = nil
        cancellables.removeAll()
    }
    
    private func setupPopover() {
        popover.contentSize = NSSize(width: Constants.popoverWidth, height: Constants.popoverHeight)
        popover.behavior = .applicationDefined
        popover.animates = true
        popover.contentViewController = NSHostingController(rootView: PopoverView(appState: appState, statusBarController: self))
    }
    
    private func setupStatusItem() {
        statusItem.button?.action = #selector(togglePopover(_:))
        statusItem.button?.target = self
        Task { @MainActor [weak self] in
            self?.updateStatusItemTitle()
        }
    }
    
    private func startUpdateTimer() {
        updateTimer?.invalidate()
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: Constants.cityRotationInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor [weak self] in
                self?.updateStatusItemTitle()
            }
        }
        
        updateTimer?.tolerance = Constants.timerTolerance
        
        if let timer = updateTimer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }
    
    @MainActor
    private func updateStatusItemTitle() {
        if let currentCity = appState.currentDisplayCity {
            let timeString = appState.getTimeString(for: currentCity, useSliderTime: true, shortFormat: true)
            statusItem.button?.title = "\(currentCity.emoji) \(currentCity.code) \(timeString)"
        } else {
            statusItem.button?.title = Constants.defaultMenuBarTitle
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
            contentRect: NSRect(x: 0, y: 0, width: Constants.settingsWindowWidth, height: Constants.settingsWindowHeight),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = Constants.citySelectionWindowTitle
        window.minSize = NSSize(width: Constants.settingsWindowWidth, height: Constants.settingsWindowHeight)
        
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

final class SettingsWindowDelegate: NSObject, NSWindowDelegate {
    weak var statusBarController: StatusBarController?
    
    init(statusBarController: StatusBarController? = nil) {
        self.statusBarController = statusBarController
        super.init()
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        return true
    }
    
    func windowWillClose(_ notification: Notification) {
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
                Text(Constants.worldClockTitle)
                    .font(.headline)
                Spacer()
                Button(Constants.quitButtonLabel) {
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
                Text("Time offset: \(Int(appState.timeSliderOffset / Constants.secondsPerHour))h")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            Divider()
            
            // Time Controls
            HStack {
                Button("← Hour") { appState.previousHour() }
                Button(Constants.resetButtonLabel) { appState.resetTime() }
                Button("Hour →") { appState.nextHour() }
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            
            // Settings
            Button(Constants.settingsButtonLabel) {
                statusBarController?.openSettingsWindow()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(Constants.defaultPadding)
        .frame(width: 300)
    }
}