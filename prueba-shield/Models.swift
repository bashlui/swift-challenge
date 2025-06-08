//
//  Models.swift
//  prueba-shield
//
//  Created by Alumno on 08/06/25.
//

import Foundation
import CoreLocation
import SwiftUICore

// MARK: - Appearance & Settings Models
enum AppearanceMode: String, CaseIterable {
    case system = "Sistema"
    case light = "Claro"
    case dark = "Oscuro"
    
    var systemName: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
    
    var displayName: String {
        switch self {
        case .system: return "Sistema"
        case .light: return "Claro"
        case .dark: return "Oscuro"
        }
    }
}

enum TemperatureUnit: String, CaseIterable {
    case celsius = "Celsius (°C)"
    case fahrenheit = "Fahrenheit (°F)"
    
    var symbol: String {
        switch self {
        case .celsius: return "°C"
        case .fahrenheit: return "°F"
        }
    }
    
    var displayName: String {
        switch self {
        case .celsius: return "Celsius"
        case .fahrenheit: return "Fahrenheit"
        }
    }
}

// MARK: - Heat Index
enum HeatIndex: String, CaseIterable {
    case safe = "Seguro"
    case caution = "Precaución"
    case warning = "Advertencia"
    case danger = "Peligro"
    case extreme = "Extremo"
    
    var color: Color {
        switch self {
        case .safe: return .green
        case .caution: return .yellow
        case .warning: return .orange
        case .danger: return .red
        case .extreme: return .purple
        }
    }
    
    var icon: String {
        switch self {
        case .safe: return "checkmark.circle.fill"
        case .caution: return "exclamationmark.triangle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .danger: return "exclamationmark.octagon.fill"
        case .extreme: return "exclamationmark.octagon.fill"
        }
    }
}

// MARK: - Weather Models
struct WeatherResponse: Codable {
    let main: Main
    let weather: [Weather]
    let wind: Wind
    
    struct Main: Codable {
        let temp: Double
        let feelsLike: Double
        let humidity: Int
        
        enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case humidity
        }
    }
    
    struct Weather: Codable {
        let main: String
        let description: String
        let icon: String
    }
    
    struct Wind: Codable {
        let speed: Double
    }
}

struct WeatherData {
    let temperature: Int
    let feelsLike: Int
    let humidity: Int
    let description: String
    let icon: String
    let windSpeed: Double
    let uvIndex: Int
    let heatIndex: HeatIndex
    
    init(from response: WeatherResponse) {
        self.temperature = Int(response.main.temp)
        self.feelsLike = Int(response.main.feelsLike)
        self.humidity = response.main.humidity
        self.description = response.weather.first?.description.capitalized ?? ""
        self.icon = WeatherData.mapWeatherIcon(response.weather.first?.icon ?? "01d")
        self.windSpeed = response.wind.speed
        self.uvIndex = 7
        self.heatIndex = WeatherData.calculateHeatIndex(temperature: Int(response.main.temp))
    }
    
    init(temperature: Int, feelsLike: Int, humidity: Int, description: String, icon: String, windSpeed: Double, uvIndex: Int, heatIndex: HeatIndex) {
        self.temperature = temperature
        self.feelsLike = feelsLike
        self.humidity = humidity
        self.description = description
        self.icon = icon
        self.windSpeed = windSpeed
        self.uvIndex = uvIndex
        self.heatIndex = heatIndex
    }
    
    static func mapWeatherIcon(_ openWeatherIcon: String) -> String {
        switch openWeatherIcon {
        case "01d", "01n": return "sun.max.fill"
        case "02d", "02n": return "cloud.sun.fill"
        case "03d", "03n", "04d", "04n": return "cloud.fill"
        case "09d", "09n", "10d", "10n": return "cloud.rain.fill"
        case "11d", "11n": return "cloud.bolt.fill"
        case "13d", "13n": return "cloud.snow.fill"
        case "50d", "50n": return "cloud.fog.fill"
        default: return "sun.max.fill"
        }
    }
    
    static func calculateHeatIndex(temperature: Int) -> HeatIndex {
        switch temperature {
        case ..<27: return .safe
        case 27..<32: return .caution
        case 32..<37: return .warning
        case 37..<42: return .danger
        default: return .extreme
        }
    }
}

// MARK: - Cool Zone Models
struct CoolZone: Identifiable {
    let id = UUID()
    let name: String
    let type: CoolZoneType
    let coordinate: CLLocationCoordinate2D
    let isOpen24Hours: Bool
    let description: String
}

enum CoolZoneType: String, CaseIterable {
    case library = "Biblioteca"
    case mall = "Centro Comercial"
    case community = "Centro Comunitario"
    case hospital = "Hospital"
    case park = "Parque con Sombra"
    
    var icon: String {
        switch self {
        case .library: return "book.fill"
        case .mall: return "building.2.fill"
        case .community: return "person.3.fill"
        case .hospital: return "cross.fill"
        case .park: return "tree.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .library: return DesignSystem.primaryBlue
        case .mall: return DesignSystem.secondaryBlue
        case .community: return DesignSystem.accentBlue
        case .hospital: return .red
        case .park: return .green
        }
    }
}
