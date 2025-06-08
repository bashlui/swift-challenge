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
    
    var detailedMessage: (title: String, reason: String, actions: [String]) {
        switch self {
        case .safe:
            return (
                title: "Condiciones Seguras",
                reason: "La temperatura está en un rango cómodo y la humedad es tolerable. El riesgo de estrés por calor es mínimo.",
                actions: [
                    "Mantén actividades normales",
                    "Hidratación regular cada hora",
                    "Aprovecha para actividades al aire libre"
                ]
            )
        case .caution:
            return (
                title: "Precaución Necesaria",
                reason: "El aumento de temperatura y humedad puede causar fatiga durante actividades prolongadas. El cuerpo comienza a trabajar más para mantener la temperatura.",
                actions: [
                    "Aumenta la frecuencia de hidratación",
                    "Toma descansos en sombra cada 30 minutos",
                    "Usa ropa ligera y de colores claros"
                ]
            )
        case .warning:
            return (
                title: "Advertencia de Calor",
                reason: "Las altas temperaturas interfieren significativamente con la capacidad del cuerpo para enfriarse. Riesgo moderado de calambres y agotamiento por calor.",
                actions: [
                    "Limita actividades exteriores intensas",
                    "Busca aire acondicionado cada 2 horas",
                    "Hidratación cada 15-20 minutos",
                    "Monitorea síntomas de agotamiento"
                ]
            )
        case .danger:
            return (
                title: "Peligro Inminente",
                reason: "El sistema de enfriamiento natural del cuerpo está sobrecargado. Alto riesgo de golpe de calor, calambres severos y deshidratación grave.",
                actions: [
                    "Evita completamente el exterior",
                    "Permanece en espacios climatizados",
                    "Hidratación constante (pequeños sorbos)",
                    "Aplica toallas frías en cuello y muñecas",
                    "Contacta servicios médicos si hay síntomas"
                ]
            )
        case .extreme:
            return (
                title: "Emergencia por Calor Extremo",
                reason: "Condiciones potencialmente letales. El cuerpo no puede regular su temperatura, causando falla de órganos vitales. Riesgo inmediato de muerte.",
                actions: [
                    "BUSCA REFUGIO INMEDIATAMENTE",
                    "Llama a servicios de emergencia",
                    "Enfriamiento corporal agresivo",
                    "No salgas bajo ninguna circunstancia",
                    "Monitoreo médico continuo"
                ]
            )
        }
    }
}

// MARK: - Weather Metrics
struct WeatherMetrics {
    let temperature: Int
    let humidity: Int
    let uvIndex: Int
    let windSpeed: Double
    let heatIndex: HeatIndex
    let airQuality: Int // 1-5 scale
    let visibility: Int // in km
    
    var temperatureProgress: Double {
        min(max(Double(temperature) / 50.0, 0.0), 1.0)
    }
    
    var humidityProgress: Double {
        Double(humidity) / 100.0
    }
    
    var uvProgress: Double {
        min(Double(uvIndex) / 11.0, 1.0)
    }
    
    var windProgress: Double {
        min(windSpeed / 50.0, 1.0)
    }
    
    var airQualityProgress: Double {
        Double(airQuality) / 5.0
    }
    
    var visibilityProgress: Double {
        min(Double(visibility) / 20.0, 1.0)
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

// MARK: - Forecast Models
struct WeatherForecastResponse: Codable {
    let cod: String
    let message: Int
    let cnt: Int
    let list: [WeatherForecastItem]
    let city: City
    
    struct WeatherForecastItem: Codable {
        let dt: Int
        let main: Main
        let weather: [Weather]
        let clouds: Clouds
        let wind: Wind
        let visibility: Int
        let pop: Double
        let rain: Rain?
        let sys: Sys
        let dtTxt: String
        
        struct Main: Codable {
            let temp: Double
            let feelsLike: Double
            let tempMin: Double
            let tempMax: Double
            let pressure: Int
            let seaLevel: Int
            let grndLevel: Int
            let humidity: Int
            let tempKf: Double
            
            enum CodingKeys: String, CodingKey {
                case temp
                case feelsLike = "feels_like"
                case tempMin = "temp_min"
                case tempMax = "temp_max"
                case pressure
                case seaLevel = "sea_level"
                case grndLevel = "grnd_level"
                case humidity
                case tempKf = "temp_kf"
            }
        }
        
        struct Weather: Codable {
            let id: Int
            let main: String
            let description: String
            let icon: String
        }
        
        struct Clouds: Codable {
            let all: Int
        }
        
        struct Wind: Codable {
            let speed: Double
            let deg: Int
            let gust: Double?
        }
        
        struct Rain: Codable {
            let threeH: Double
            
            enum CodingKeys: String, CodingKey {
                case threeH = "3h"
            }
        }
        
        struct Sys: Codable {
            let pod: String
        }
        
        enum CodingKeys: String, CodingKey {
            case dt, main, weather, clouds, wind, visibility, pop, rain, sys
            case dtTxt = "dt_txt"
        }
    }
    
    struct City: Codable {
        let id: Int
        let name: String
        let coord: Coord
        let country: String
        let population: Int
        let timezone: Int
        let sunrise: Int
        let sunset: Int
        
        struct Coord: Codable {
            let lat: Double
            let lon: Double
        }
    }
}

struct DailyForecast: Identifiable {
    let id = UUID()
    let date: Date
    let dayName: String
    let maxTemp: Int
    let minTemp: Int
    let description: String
    let icon: String
    let precipitationProbability: Int
    let heatIndex: HeatIndex
    
    static func fromForecastItems(_ items: [WeatherForecastResponse.WeatherForecastItem]) -> [DailyForecast] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        // Group by day
        let groupedByDay = Dictionary(grouping: items) { item in
            let date = dateFormatter.date(from: item.dtTxt) ?? Date()
            return Calendar.current.startOfDay(for: date)
        }
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE"
        
        return groupedByDay.map { (date, items) in
            let temperatures = items.map { Int($0.main.temp) }
            let maxTemp = temperatures.max() ?? 0
            let minTemp = temperatures.min() ?? 0
            let avgPrecipitation = items.reduce(0) { $0 + $1.pop } / Double(items.count)
            
            // Use midday item for description and icon
            let middayItem = items.first { item in
                let itemDate = dateFormatter.date(from: item.dtTxt) ?? Date()
                let hour = Calendar.current.component(.hour, from: itemDate)
                return hour >= 12 && hour <= 15
            } ?? items.first!
            
            return DailyForecast(
                date: date,
                dayName: dayFormatter.string(from: date),
                maxTemp: maxTemp,
                minTemp: minTemp,
                description: middayItem.weather.first?.description.capitalized ?? "",
                icon: WeatherData.mapWeatherIcon(middayItem.weather.first?.icon ?? "01d"),
                precipitationProbability: Int(avgPrecipitation * 100),
                heatIndex: WeatherData.calculateHeatIndex(temperature: maxTemp)
            )
        }.sorted { $0.date < $1.date }
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
