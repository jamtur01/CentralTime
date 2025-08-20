import SwiftUI
import Foundation

final class AppState: ObservableObject {
    @Published var selectedCities = TimeZoneManager.getDefaultCities()
    @Published var currentCityIndex = 0
    @Published var timeSliderOffset: TimeInterval = 0
    @Published var isSettingsWindowOpen = false
    
    private let timer = TimerManager()
    
    let allAvailableTimezones = TimeZoneManager.getAllAvailableCities()
    
    var currentDisplayCity: City? {
        guard !selectedCities.isEmpty else { return nil }
        return selectedCities[currentCityIndex]
    }
    
    init() {
        startTimer()
    }
    
    deinit {
        timer.stop()
    }
    
    private func startTimer() {
        timer.start(
            interval: Constants.cityRotationInterval,
            tolerance: Constants.timerTolerance
        ) { [weak self] in
            self?.rotateToNextCity()
        }
    }
    
    private func rotateToNextCity() {
        guard !selectedCities.isEmpty else { return }
        currentCityIndex = (currentCityIndex + 1) % selectedCities.count
    }
    
    @MainActor
    func getTimeString(for city: City, useSliderTime: Bool = false, shortFormat: Bool = false) -> String {
        let baseDate = useSliderTime ? Date().addingTimeInterval(timeSliderOffset) : Date()
        return shortFormat 
            ? DateFormatterManager.formatShortTime(for: city, date: baseDate)
            : DateFormatterManager.formatLongTime(for: city, date: baseDate)
    }
    
    
    func previousHour() {
        timeSliderOffset -= Constants.secondsPerHour
    }
    
    func nextHour() {
        timeSliderOffset += Constants.secondsPerHour
    }
    
    func resetTime() {
        timeSliderOffset = 0
    }
    
    func updateSelectedCities(_ cities: [City]) {
        selectedCities = TimeZoneManager.sortCitiesByTimezone(cities)
        currentCityIndex = 0
    }
    
}