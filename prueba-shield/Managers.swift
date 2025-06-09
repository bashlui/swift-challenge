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
    @Published var dailyForecast: [DailyForecast] = []
    @Published var isLoading = false
    @Published var isLoadingForecast = false
    @Published var errorMessage: String?
    
    private let apiKey = ""
    
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
    
    func fetchForecast(for location: CLLocation) {
        guard !apiKey.isEmpty && apiKey != "TU_API_KEY_AQUI" else {
            loadMockForecast()
            return
        }
        
        isLoadingForecast = true
        
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric&lang=es"
        
        guard let url = URL(string: urlString) else {
            self.isLoadingForecast = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoadingForecast = false
                
                if let error = error {
                    print("Error fetching forecast: \(error.localizedDescription)")
                    self.loadMockForecast()
                    return
                }
                
                guard let data = data else {
                    self.loadMockForecast()
                    return
                }
                
                do {
                    let forecastResponse = try JSONDecoder().decode(WeatherForecastResponse.self, from: data)
                    self.dailyForecast = DailyForecast.fromForecastItems(forecastResponse.list)
                } catch {
                    print("Error decoding forecast: \(error.localizedDescription)")
                    self.loadMockForecast()
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
    
    func getWeatherMetrics() -> WeatherMetrics? {
        guard let weather = currentWeather else { return nil }
        
        return WeatherMetrics(
            temperature: weather.temperature,
            humidity: weather.humidity,
            uvIndex: weather.uvIndex,
            windSpeed: weather.windSpeed,
            heatIndex: weather.heatIndex,
            airQuality: generateAirQuality(for: weather.temperature),
            visibility: generateVisibility(for: weather.humidity)
        )
    }
    
    private func generateAirQuality(for temperature: Int) -> Int {
        // Simular calidad del aire basada en temperatura
        switch temperature {
        case ..<25: return 1 // Excelente
        case 25..<30: return 2 // Buena
        case 30..<35: return 3 // Moderada
        case 35..<40: return 4 // Mala
        default: return 5 // Peligrosa
        }
    }
    
    private func generateVisibility(for humidity: Int) -> Int {
        // Simular visibilidad basada en humedad
        switch humidity {
        case ..<30: return 20 // Excelente visibilidad
        case 30..<60: return 15 // Buena visibilidad
        case 60..<80: return 10 // Moderada
        default: return 5 // Reducida
        }
    }
    
    private func loadMockForecast() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let calendar = Calendar.current
            let today = Date()
            
            self.dailyForecast = (1...5).map { dayOffset in
                let date = calendar.date(byAdding: .day, value: dayOffset, to: today) ?? today
                let dayFormatter = DateFormatter()
                dayFormatter.dateFormat = "EEEE"
                
                let temps = [32, 35, 38, 33, 30]
                let descriptions = ["Soleado", "Muy caluroso", "Calor extremo", "Caluroso", "Templado"]
                let icons = ["sun.max.fill", "sun.max.fill", "sun.max.fill", "cloud.sun.fill", "cloud.fill"]
                
                let temp = temps[dayOffset - 1]
                
                return DailyForecast(
                    date: date,
                    dayName: dayFormatter.string(from: date),
                    maxTemp: temp,
                    minTemp: temp - 8,
                    description: descriptions[dayOffset - 1],
                    icon: icons[dayOffset - 1],
                    precipitationProbability: [10, 5, 0, 20, 40][dayOffset - 1],
                    heatIndex: WeatherData.calculateHeatIndex(temperature: temp)
                )
            }
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

// MARK: - Enhanced Notification Manager
class NotificationManager: ObservableObject {
    @Published var isAuthorized = false
    @Published var sunscreenRemindersEnabled = true
    @Published var hydrationRemindersEnabled = true
    @Published var sunscreenInterval: Double = 2.0 // horas
    @Published var hydrationInterval: Double = 2.0 // horas
    
    private var sunscreenTimer: Timer?
    private var hydrationTimer: Timer?
    
    init() {
        checkAuthorizationStatus()
        loadReminderSettings()
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                if granted {
                    self.setupReminders()
                }
            }
        }
    }
    
    private func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
                if self.isAuthorized {
                    self.setupReminders()
                }
            }
        }
    }
    
    private func loadReminderSettings() {
        sunscreenRemindersEnabled = UserDefaults.standard.bool(forKey: "sunscreenRemindersEnabled")
        hydrationRemindersEnabled = UserDefaults.standard.bool(forKey: "hydrationRemindersEnabled")
        
        if let savedSunscreenInterval = UserDefaults.standard.object(forKey: "sunscreenInterval") as? Double {
            sunscreenInterval = savedSunscreenInterval
        }
        
        if let savedHydrationInterval = UserDefaults.standard.object(forKey: "hydrationInterval") as? Double {
            hydrationInterval = savedHydrationInterval
        }
    }
    
    func saveReminderSettings() {
        UserDefaults.standard.set(sunscreenRemindersEnabled, forKey: "sunscreenRemindersEnabled")
        UserDefaults.standard.set(hydrationRemindersEnabled, forKey: "hydrationRemindersEnabled")
        UserDefaults.standard.set(sunscreenInterval, forKey: "sunscreenInterval")
        UserDefaults.standard.set(hydrationInterval, forKey: "hydrationInterval")
        
        setupReminders()
    }
    
    func setupReminders() {
        // Cancelar recordatorios existentes
        cancelAllReminders()
        
        guard isAuthorized else { return }
        
        if sunscreenRemindersEnabled {
            scheduleSunscreenReminder()
        }
        
        if hydrationRemindersEnabled {
            scheduleHydrationReminder()
        }
    }
    
    private func scheduleSunscreenReminder() {
        let content = UNMutableNotificationContent()
        content.title = "☀️ Protección Solar"
        content.body = "Es hora de reaplicar tu bloqueador solar. Protege tu piel del sol."
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "SUNSCREEN_REMINDER"
        
        // Crear trigger repetitivo
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: sunscreenInterval * 3600, // convertir horas a segundos
            repeats: true
        )
        
        let request = UNNotificationRequest(
            identifier: "sunscreen_reminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling sunscreen reminder: \(error)")
            }
        }
    }
    
    private func scheduleHydrationReminder() {
        let content = UNMutableNotificationContent()
        content.title = "💧 Hora de Hidratarte"
        content.body = "Bebe agua para mantenerte fresco y saludable. Tu cuerpo lo necesita."
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "HYDRATION_REMINDER"
        
        // Crear trigger repetitivo
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: hydrationInterval * 3600, // convertir horas a segundos
            repeats: true
        )
        
        let request = UNNotificationRequest(
            identifier: "hydration_reminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling hydration reminder: \(error)")
            }
        }
    }
    
    func scheduleHeatAlert(temperature: Int, threshold: Double) {
        guard isAuthorized, Double(temperature) >= threshold else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Alerta de Calor Extremo"
        content.body = "Temperatura actual: \(temperature)°C. Busca refugio inmediatamente."
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "HEAT_ALERT"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "heat_alert_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["sunscreen_reminder", "hydration_reminder"]
        )
    }
    
    func cancelSunscreenReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["sunscreen_reminder"]
        )
    }
    
    func cancelHydrationReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["hydration_reminder"]
        )
    }
    
    // Métodos de utilidad para obtener el próximo recordatorio
    func getNextReminderTimes() -> (sunscreen: Date?, hydration: Date?) {
        let now = Date()
        
        let sunscreenNext = sunscreenRemindersEnabled ?
            now.addingTimeInterval(sunscreenInterval * 3600) : nil
        
        let hydrationNext = hydrationRemindersEnabled ?
            now.addingTimeInterval(hydrationInterval * 3600) : nil
        
        return (sunscreenNext, hydrationNext)
    }
}
