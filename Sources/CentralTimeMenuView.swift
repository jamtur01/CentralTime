import SwiftUI

struct CentralTimeMenuView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("🌍 World Clock")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Button("✕") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            
            // Cities List
            VStack(spacing: 8) {
                ForEach(appState.selectedCities, id: \.timeZoneIdentifier) { city in
                    HStack(spacing: 12) {
                        Text(city.emoji)
                            .font(.system(size: 16))
                            .frame(width: 20)
                        
                        Text(city.code)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.primary)
                            .frame(width: 40, alignment: .leading)
                        
                        Text(city.displayName)
                            .font(.system(.body))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(appState.getTimeString(for: city, useSliderTime: true))
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.secondary)
                            .frame(width: 80, alignment: .trailing)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                    .background(Color.clear)
                }
            }
            
            if appState.timeSliderOffset != 0 {
                HStack {
                    Text("🕐 Time offset: \(Int(appState.timeSliderOffset / 3600))h")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
            
            Divider()
                .padding(.horizontal, 16)
            
            // Controls
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Button("← Hour") {
                        appState.previousHour()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    
                    Button("Reset") {
                        appState.resetTime()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    
                    Button("Hour →") {
                        appState.nextHour()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
                
                Button("⚙️ Settings") {
                    openWindow(id: "city-selection")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(.regularMaterial)
    }
}

#Preview {
    CentralTimeMenuView()
        .environmentObject(AppState())
        .frame(width: 340, height: 400)
}