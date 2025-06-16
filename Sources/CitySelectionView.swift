import SwiftUI

struct CitySelectionView: View {
    @EnvironmentObject var appState: AppState
    @State private var searchText = ""
    @State private var selectedCityCodes: Set<String> = []
    let onClose: () -> Void
    
    init(onClose: @escaping () -> Void = {}) {
        self.onClose = onClose
    }
    
    var filteredCities: [City] {
        let cities = appState.allAvailableTimezones.sorted { $0.displayName < $1.displayName }
        
        if searchText.isEmpty {
            return cities
        } else {
            return cities.filter { city in
                city.displayName.localizedCaseInsensitiveContains(searchText) ||
                city.code.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Select Cities")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Choose cities to display in your timezone list:")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search cities...", text: $searchText)
                    .textFieldStyle(.plain)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            
            // City list
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(filteredCities, id: \.timeZoneIdentifier) { city in
                        CitySelectionRow(
                            city: city,
                            isSelected: selectedCityCodes.contains(city.code)
                        ) { isSelected in
                            if isSelected {
                                selectedCityCodes.insert(city.code)
                            } else {
                                selectedCityCodes.remove(city.code)
                            }
                        }
                        .padding(.horizontal, 4)
                        
                        if city.timeZoneIdentifier != filteredCities.last?.timeZoneIdentifier {
                            Divider()
                                .padding(.leading, 40)
                        }
                    }
                }
            }
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            
            // Action buttons
            HStack {
                Button("Cancel") {
                    onClose()
                }
                .keyboardShortcut(.escape, modifiers: [])
                
                Spacer()
                
                Text("\(selectedCityCodes.count) cities selected")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("Save") {
                    let selectedCities = appState.allAvailableTimezones.filter { 
                        selectedCityCodes.contains($0.code) 
                    }
                    appState.updateSelectedCities(selectedCities)
                    onClose()
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedCityCodes.isEmpty)
                .keyboardShortcut(.return, modifiers: [])
            }
        }
        .padding(20)
        .onAppear {
            selectedCityCodes = Set(appState.selectedCities.map { $0.code })
        }
    }
    
    private func closeWindow() {
        // Close the current window properly without terminating the app
        DispatchQueue.main.async {
            if let window = NSApplication.shared.keyWindow {
                window.performClose(nil)
            } else if let window = NSApplication.shared.windows.first(where: { $0.title == "City Selection" }) {
                window.performClose(nil)
            }
        }
    }
}

struct CitySelectionRow: View {
    let city: City
    let isSelected: Bool
    let onToggle: (Bool) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button(action: { onToggle(!isSelected) }) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(isSelected ? .accentColor : .secondary)
                    .font(.system(size: 16))
            }
            .buttonStyle(.plain)
            
            // City info
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("\(city.emoji) \(city.code)")
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(.medium)
                    
                    Text(city.displayName)
                        .font(.body)
                    
                    Spacer()
                    
                    Text(getCurrentTimeString(for: city))
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                
                Text(city.timeZoneIdentifier)
                    .font(.caption)
                    .foregroundColor(Color(NSColor.tertiaryLabelColor))
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            onToggle(!isSelected)
        }
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        )
    }
    
    private func getCurrentTimeString(for city: City) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = city.timeZone
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: Date())
    }
}

#Preview {
    CitySelectionView(onClose: {})
        .environmentObject(AppState())
        .frame(width: 500, height: 600)
}