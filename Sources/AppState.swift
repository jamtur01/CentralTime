import SwiftUI
import Foundation

final class AppState: ObservableObject {
    @Published var selectedCities = TimeZoneManager.getDefaultCities()
    @Published var currentCityIndex = 0
    @Published var timeSliderOffset: TimeInterval = 0
    @Published var isSettingsWindowOpen = false
    
    private var timer: Timer?
    
    let allAvailableTimezones = TimeZoneManager.getAllAvailableCities()
    
    var currentDisplayCity: City? {
        guard !selectedCities.isEmpty else { return nil }
        return selectedCities[currentCityIndex]
    }
    
    init() {
        startTimer()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    private func startTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: Constants.cityRotationInterval, repeats: true) { [weak self] _ in
            self?.rotateToNextCity()
        }
        
        timer?.tolerance = Constants.timerTolerance
        
        if let timer = timer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }
    
    private func rotateToNextCity() {
        guard !selectedCities.isEmpty else { return }
        currentCityIndex = (currentCityIndex + 1) % selectedCities.count
    }
    
    @MainActor
    func getTimeString(for city: City, useSliderTime: Bool = false, shortFormat: Bool = false) -> String {
        let baseDate = useSliderTime ? Date().addingTimeInterval(timeSliderOffset) : Date()
        let formatter = shortFormat ? DateFormatterManager.shortFormatter : DateFormatterManager.longFormatter
        
        if formatter.timeZone != city.timeZone {
            formatter.timeZone = city.timeZone
        }
        
        return formatter.string(from: baseDate)
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