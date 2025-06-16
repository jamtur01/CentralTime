# Changelog

All notable changes to CentralTime will be documented in this file.

## [2.0.0] - 2025-01-XX

### 🎨 Complete UI Redesign
- **Modern SwiftUI Interface**: Redesigned with clean, single-line city displays
- **Dynamic Menu Bar**: Shows rotating city emoji, code, and time every 3 seconds
- **Proper Status Bar Implementation**: Uses NSStatusItem + NSPopover for reliable updates
- **Improved Typography**: Better font choices and spacing for readability

### 🌍 Enhanced City Management
- **Timezone Sorting**: Cities now automatically sorted by timezone offset (west to east)
- **Search Interface**: Improved city selection with real-time search functionality
- **Duplicate Prevention**: Fixed issues where multiple copies of cities would appear
- **Better Data Management**: Replaced hardcoded data with dynamic TimeZoneManager

### ⚙️ Settings Experience
- **Fixed Window Sizing**: Settings window now opens at proper size without manual resizing
- **Proper Window Management**: Cancel/Save buttons no longer terminate the entire app
- **Conflict Resolution**: Settings can be reopened multiple times without issues
- **Keyboard Shortcuts**: Escape to cancel, Return to save

### 🔧 Technical Improvements
- **TimeZone API Integration**: Uses Swift's built-in TimeZone APIs instead of hardcoded data
- **Better Architecture**: Clean separation between AppKit status bar and SwiftUI content
- **Error Handling**: Improved window lifecycle and error management
- **Code Organization**: Better structure with dedicated TimeZoneManager

### 🐛 Bug Fixes
- Fixed duplicate cities appearing in dropdown
- Fixed settings window closing entire app
- Fixed timezone rotation not working correctly
- Fixed menu bar text not updating dynamically
- Fixed popover not responding to clicks

## [1.0.0] - 2024-XX-XX

### Initial Release
- Basic timezone display functionality
- Simple city selection
- Menu bar presence
- Basic time controls