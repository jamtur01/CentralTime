import SwiftUI
import AppKit

final class StatusBarController {
    private var statusBar: NSStatusBar
    private var statusItem: NSStatusItem
    private var popover: NSPopover
    private let appState = AppState()
    private let updateTimer = TimerManager()
    weak var settingsWindow: NSWindow?
    internal var settingsWindowDelegate: SettingsWindowDelegate?
    
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
        updateTimer.stop()
    }
    
    func cleanup() {
        updateTimer.stop()
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
        updateTimer.start(
            interval: Constants.cityRotationInterval,
            tolerance: Constants.timerTolerance
        ) { [weak self] in
            guard let self = self else { return }
            Task { @MainActor [weak self] in
                self?.updateStatusItemTitle()
            }
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
        settingsWindowDelegate = delegate
        window.delegate = delegate
        
        let citySelectionView = CitySelectionView(onClose: {
            DispatchQueue.main.async {
                self.settingsWindow = nil
                self.settingsWindowDelegate = nil
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