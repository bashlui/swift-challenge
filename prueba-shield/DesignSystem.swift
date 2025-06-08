//
//  DesignSystem.swift
//  prueba-shield
//
//  Created by Alumno on 08/06/25.
//

import SwiftUI

// MARK: - Design System
struct DesignSystem {
    // Color Palette
    static let primaryBlue = Color(red: 0.0, green: 0.48, blue: 0.91)
    static let secondaryBlue = Color(red: 0.25, green: 0.63, blue: 0.95)
    static let lightBlue = Color(red: 0.9, green: 0.95, blue: 1.0)
    static let darkBlue = Color(red: 0.0, green: 0.32, blue: 0.65)
    static let accentBlue = Color(red: 0.0, green: 0.6, blue: 1.0)
    
    // Adaptive Colors
    static let white = Color(.systemBackground)
    static let lightGray = Color(.secondarySystemBackground)
    static let mediumGray = Color(.tertiarySystemBackground)
    static let textGray = Color(.secondaryLabel)
    static let borderGray = Color(.separator)
    static let primaryText = Color(.label)
    
    // Fonts
    static func title1() -> Font { .system(size: 28, weight: .bold, design: .default) }
    static func title2() -> Font { .system(size: 22, weight: .semibold, design: .default) }
    static func headline() -> Font { .system(size: 18, weight: .semibold, design: .default) }
    static func body() -> Font { .system(size: 16, weight: .regular, design: .default) }
    static func caption() -> Font { .system(size: 12, weight: .medium, design: .default) }
    
    // Metrics
    static let padding: CGFloat = 16
    static let spacing: CGFloat = 12
    static let cornerRadius: CGFloat = 12
    static let shadowRadius: CGFloat = 8
}

// MARK: - Custom Components
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DesignSystem.headline())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [DesignSystem.primaryBlue, DesignSystem.secondaryBlue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.cornerRadius))
                .shadow(color: DesignSystem.primaryBlue.opacity(0.3), radius: 4, y: 2)
        }
    }
}

struct CardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(DesignSystem.padding)
            .background(DesignSystem.white)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.cornerRadius))
            .shadow(color: Color.black.opacity(0.08), radius: DesignSystem.shadowRadius, y: 2)
    }
}

struct GradientBackground: View {
    var body: some View {
        LinearGradient(
            colors: [DesignSystem.lightBlue, DesignSystem.white],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct QuickActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: [Color]
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(DesignSystem.headline())
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.primaryText)
                        .multilineTextAlignment(.center)
                    
                    Text(subtitle)
                        .font(DesignSystem.caption())
                        .foregroundColor(DesignSystem.textGray)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.padding)
            .background(DesignSystem.white)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.cornerRadius))
            .shadow(color: Color.black.opacity(0.08), radius: 6, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct WeatherCard: View {
    @ObservedObject var weatherManager: WeatherManager
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var themeManager: ThemeManager
    
    var body: some View {
        CardView {
            VStack(spacing: 16) {
                if weatherManager.isLoading {
                    HStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(DesignSystem.primaryBlue)
                        Text("Obteniendo datos meteorológicos...")
                            .font(DesignSystem.body())
                            .foregroundColor(DesignSystem.textGray)
                    }
                    .frame(height: 60)
                } else if let weather = weatherManager.currentWeather {
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Condiciones Actuales")
                                    .font(DesignSystem.headline())
                                    .foregroundColor(DesignSystem.primaryText)
                                Text("Monterrey, Nuevo León")
                                    .font(DesignSystem.caption())
                                    .foregroundColor(DesignSystem.textGray)
                            }
                            
                            Spacer()
                            
                            Image(systemName: weather.icon)
                                .font(.title)
                                .foregroundColor(DesignSystem.primaryBlue)
                        }
                        
                        HStack(alignment: .bottom, spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(alignment: .bottom, spacing: 4) {
                                    Text(formatTemperature(weather.temperature, unit: themeManager.temperatureUnit))
                                        .font(.system(size: 36, weight: .bold, design: .rounded))
                                        .foregroundColor(DesignSystem.primaryText)
                                    Text(themeManager.temperatureUnit.symbol)
                                        .font(DesignSystem.title2())
                                        .foregroundColor(DesignSystem.textGray)
                                        .offset(y: -4)
                                }
                                
                                Text("Sensación \(formatTemperature(weather.feelsLike, unit: themeManager.temperatureUnit))\(themeManager.temperatureUnit.symbol)")
                                    .font(DesignSystem.caption())
                                    .foregroundColor(DesignSystem.textGray)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 6) {
                                Image(systemName: weather.heatIndex.icon)
                                    .font(.caption)
                                Text(weather.heatIndex.rawValue)
                                    .font(DesignSystem.caption())
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                LinearGradient(
                                    colors: [weather.heatIndex.color, weather.heatIndex.color.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        HStack(spacing: 20) {
                            WeatherDetailItem(icon: "drop.fill", value: "\(weather.humidity)%", label: "Humedad")
                            WeatherDetailItem(icon: "wind", value: "\(Int(weather.windSpeed)) km/h", label: "Viento")
                            WeatherDetailItem(icon: "sun.max.fill", value: "UV \(weather.uvIndex)", label: "Índice UV")
                        }
                    }
                } else if let error = weatherManager.errorMessage {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(DesignSystem.primaryBlue)
                            .font(.title2)
                        Text("Error obteniendo clima")
                            .font(DesignSystem.headline())
                            .foregroundColor(DesignSystem.primaryText)
                        Text(error)
                            .font(DesignSystem.caption())
                            .foregroundColor(DesignSystem.textGray)
                            .multilineTextAlignment(.center)
                    }
                    .frame(height: 80)
                }
            }
        }
        .onChange(of: locationManager.location) { oldValue, newValue in
            if let location = newValue {
                weatherManager.fetchWeather(for: location)
            }
        }
    }
    
    private func formatTemperature(_ temp: Int, unit: TemperatureUnit) -> String {
        switch unit {
        case .celsius:
            return "\(temp)"
        case .fahrenheit:
            return "\(Int(Double(temp) * 9/5 + 32))"
        }
    }
}

struct WeatherDetailItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(DesignSystem.primaryBlue)
                .font(.caption)
            Text(value)
                .font(DesignSystem.caption())
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.primaryText)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(DesignSystem.textGray)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - View Extensions
extension View {
    func heatShieldStyle() -> some View {
        self
            .background(DesignSystem.white)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.cornerRadius))
            .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
    }
}
