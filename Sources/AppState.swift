import SwiftUI
import Foundation

class AppState: ObservableObject {
    @Published var selectedCities = TimeZoneData.defaultTimezones
    @Published var currentCityIndex = 0
    @Published var timeSliderOffset: TimeInterval = 0
    @Published var currentTimeString = ""
    @Published var isSettingsWindowOpen = false
    
    private var timer: Timer?
    
    let allAvailableTimezones = TimeZoneData.allTimezones
    
    var currentDisplayCity: City? {
        guard !selectedCities.isEmpty else { return nil }
        return selectedCities[currentCityIndex]
    }
    
    init() {
        updateCurrentTime()
        startTimer()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func startTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.updateCurrentTime()
            self?.rotateToNextCity()
        }
        
        // Ensure timer works in all run loop modes
        if let timer = timer {
            RunLoop.current.add(timer, forMode: .common)
        }
        
        updateCurrentTime()
    }
    
    private func rotateToNextCity() {
        guard !selectedCities.isEmpty else { return }
        currentCityIndex = (currentCityIndex + 1) % selectedCities.count
    }
    
    private func updateCurrentTime() {
        guard let currentCity = currentDisplayCity else {
            currentTimeString = ""
            return
        }
        
        let baseDate = Date().addingTimeInterval(timeSliderOffset)
        let formatter = DateFormatter()
        formatter.timeZone = currentCity.timeZone
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US")
        
        currentTimeString = formatter.string(from: baseDate)
    }
    
    func getTimeString(for city: City, useSliderTime: Bool = false, shortFormat: Bool = false) -> String {
        let baseDate = useSliderTime ? Date().addingTimeInterval(timeSliderOffset) : Date()
        let formatter = DateFormatter()
        formatter.timeZone = city.timeZone
        formatter.locale = Locale(identifier: "en_US")
        
        if shortFormat {
            formatter.dateFormat = "h:mm a"
        } else {
            formatter.dateFormat = "EEE h:mm a"
        }
        
        return formatter.string(from: baseDate)
    }
    
    // Time slider controls
    func previousHour() {
        timeSliderOffset -= 3600 // 1 hour in seconds
        updateCurrentTime()
    }
    
    func nextHour() {
        timeSliderOffset += 3600 // 1 hour in seconds
        updateCurrentTime()
    }
    
    func resetTime() {
        timeSliderOffset = 0
        updateCurrentTime()
    }
    
    func updateSelectedCities(_ cities: [City]) {
        selectedCities = cities
        currentCityIndex = 0
        updateCurrentTime()
    }
    
}