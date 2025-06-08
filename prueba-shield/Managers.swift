//
//  Managers.swift
//  prueba-shield
//
//  Created by Alumno on 08/06/25.
//

import Foundation
import CoreLocation
import UserNotifications
import SwiftUI

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    @Published var appearanceMode: AppearanceMode = .system
    @Published var temperatureUnit: TemperatureUnit = .celsius
    @Published var notificationsEnabled: Bool = true
    @Published var soundEnabled: Bool = true
    @Published var hapticEnabled: Bool = true
    
    init() {
        loadSettings()
    }
    
    private func loadSettings() {
        if let savedMode = UserDefaults.standard.object(forKey: "appearanceMode") as? String,
           let mode = AppearanceMode(rawValue: savedMode) {
            appearanceMode = mode
        }
        
        if let savedUnit = UserDefaults.standard.object(forKey: "temperatureUnit") as? String,
           let unit = TemperatureUnit(rawValue: savedUnit) {
            temperatureUnit = unit
        }
        
        notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        soundEnabled = UserDefaults.standard.bool(forKey: "soundEnabled")
        hapticEnabled = UserDefaults.standard.bool(forKey: "hapticEnabled")
    }
    
    func saveSettings() {
        UserDefaults.standard.set(appearanceMode.rawValue, forKey: "appearanceMode")
        UserDefaults.standard.set(temperatureUnit.rawValue, forKey: "temperatureUnit")
        UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        UserDefaults.standard.set(soundEnabled, forKey: "soundEnabled")
        UserDefaults.standard.set(hapticEnabled, forKey: "hapticEnabled")
    }
}

// MARK: - Weather Manager
class WeatherManager: ObservableObject {
    @Published var currentWeather: WeatherData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiKey = "TU_API_KEY_AQUI"
    
    func fetchWeather(for location: CLLocation) {
        guard !apiKey.isEmpty && apiKey != "TU_API_KEY_AQUI" else {
            loadMockWeather()
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric&lang=es"
        
        guard let url = URL(string: urlString) else {
            self.errorMessage = "URL inválida"
            self.isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Error de conexión: \(error.localizedDescription)"
                    self.loadMockWeather()
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No se recibieron datos"
                    self.loadMockWeather()
                    return
                }
                
                do {
                    let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                    self.currentWeather = WeatherData(from: weatherResponse)
                } catch {
                    self.errorMessage = "Error procesando datos: \(error.localizedDescription)"
                    self.loadMockWeather()
                }
            }
        }.resume()
    }
    
    private func loadMockWeather() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.currentWeather = WeatherData(
                temperature: 34,
                feelsLike: 38,
                humidity: 65,
                description: "Calor extremo",
                icon: "sun.max.fill",
                windSpeed: 12,
                uvIndex: 8,
                heatIndex: .extreme
            )
        }
    }
}

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLoading = false
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startLocationUpdates() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            return
        }
        isLoading = true
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        self.isLoading = false
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting location: \(error)")
        isLoading = false
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            startLocationUpdates()
        }
    }
    
    func distanceToZone(_ zone: CoolZone) -> Double? {
        guard let userLocation = location else { return nil }
        let zoneLocation = CLLocation(latitude: zone.coordinate.latitude, longitude: zone.coordinate.longitude)
        return userLocation.distance(from: zoneLocation)
    }
}

// MARK: - Notification Manager
class NotificationManager: ObservableObject {
    @Published var isAuthorized = false
    
    init() {
        checkAuthorizationStatus()
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
            }
        }
    }
    
    private func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func scheduleHeatAlert(temperature: Int, threshold: Double) {
        guard isAuthorized, Double(temperature) >= threshold else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Alerta de Calor Extremo"
        content.body = "Temperatura actual: \(temperature)°C. Busca refugio inmediatamente."
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
