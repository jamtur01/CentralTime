import SwiftUI

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