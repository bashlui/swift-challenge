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

// MARK: - Interactive Components
struct InteractiveDetailItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .scaleEffect(isPressed ? 1.2 : 1.0)
                
                VStack(spacing: 2) {
                    Text(value)
                        .font(DesignSystem.body())
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.primaryText)
                    
                    Text(title)
                        .font(DesignSystem.caption())
                        .foregroundColor(DesignSystem.textGray)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isPressed ? color.opacity(0.1) : DesignSystem.lightGray)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EnhancedQuickActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: [Color]
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                        .shadow(color: gradient.first?.opacity(0.4) ?? .clear, radius: isSelected ? 8 : 4)
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(.white)
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(DesignSystem.headline())
                        .fontWeight(isSelected ? .bold : .semibold)
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
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.cornerRadius)
                    .fill(DesignSystem.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.cornerRadius)
                            .stroke(isSelected ? gradient.first ?? DesignSystem.primaryBlue : Color.clear, lineWidth: 2)
                    )
            )
            .shadow(color: Color.black.opacity(isSelected ? 0.15 : 0.08), radius: isSelected ? 10 : 6, y: 2)
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmergencyOverlay: View {
    let onDismiss: () -> Void
    @State private var animateWarning = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }
            
            VStack(spacing: 24) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.red)
                    .scaleEffect(animateWarning ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: animateWarning)
                
                VStack(spacing: 16) {
                    Text("Modo Emergencia")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Acciones rápidas para situaciones críticas")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 12) {
                    EmergencyButton(title: "🚨 Llamar Emergencias", subtitle: "911") {
                        if let phoneURL = URL(string: "tel://911") {
                            UIApplication.shared.open(phoneURL)
                        }
                    }
                    
                    EmergencyButton(title: "🗺️ Refugio Más Cercano", subtitle: "Ir al mapa") {
                        onDismiss()
                        // selectedTab = 1 // Se implementaría con binding
                    }
                    
                    EmergencyButton(title: "📞 Contacto de Emergencia", subtitle: "Llamar contacto") {
                        // Implementar contacto de emergencia
                    }
                }
                
                Button("Cerrar") {
                    onDismiss()
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
            }
            .frame(maxWidth: 300)
        }
        .onAppear {
            animateWarning = true
        }
    }
}

struct EmergencyButton: View {
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.white)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.red.opacity(0.8))
            )
        }
    }
}
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
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Group {
            if colorScheme == .dark {
                Color.black
                    .ignoresSafeArea()
            } else {
                LinearGradient(
                    colors: [DesignSystem.lightBlue, DesignSystem.white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
        }
    }
}

// MARK: - Climate Care Charts
struct ClimateCareChartsCard: View {
    let weather: WeatherData
    @State private var animateCharts = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Detalles de Cuidado Climático")
                    .font(DesignSystem.headline())
                    .foregroundColor(DesignSystem.primaryText)
                Spacer()
                Image(systemName: "heart.circle.fill")
                    .foregroundColor(.red)
                    .font(.title3)
            }
            
            VStack(spacing: 16) {
                // Gráfica de hidratación
                HydrationChart(temperature: weather.temperature, animateCharts: animateCharts)
                
                // Gráfica de exposición solar segura
                SunExposureChart(uvIndex: weather.uvIndex, animateCharts: animateCharts)
                
                // Gráfica de riesgo por tiempo de exposición
                ExposureRiskChart(heatIndex: weather.heatIndex, animateCharts: animateCharts)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).delay(0.5)) {
                animateCharts = true
            }
        }
    }
}

struct HydrationChart: View {
    let temperature: Int
    let animateCharts: Bool
    
    private var hydrationData: [(String, Double, Color)] {
        let baseNeed = 2.0 // Litros base
        let extraNeed = max(0, Double(temperature - 25)) * 0.3 // Extra por calor
        let totalNeed = baseNeed + extraNeed
        
        return [
            ("Normal", baseNeed / totalNeed, DesignSystem.primaryBlue),
            ("Por calor", extraNeed / totalNeed, .orange),
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "drop.fill")
                    .foregroundColor(DesignSystem.primaryBlue)
                Text("Necesidad de Hidratación")
                    .font(DesignSystem.body())
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.primaryText)
                Spacer()
                Text("\(String(format: "%.1f", hydrationData.reduce(0) { $0 + $1.1 } * 3.5))L/día")
                    .font(DesignSystem.caption())
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.primaryBlue)
            }
            
            HStack(spacing: 4) {
                ForEach(Array(hydrationData.enumerated()), id: \.offset) { index, data in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(data.2)
                        .frame(height: 8)
                        .frame(width: animateCharts ? CGFloat(data.1 * 200) : 0)
                        .animation(.easeInOut(duration: 0.8).delay(Double(index) * 0.2), value: animateCharts)
                }
            }
            
            HStack {
                ForEach(hydrationData, id: \.0) { data in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(data.2)
                            .frame(width: 8, height: 8)
                        Text(data.0)
                            .font(.system(size: 10))
                            .foregroundColor(DesignSystem.textGray)
                    }
                }
                Spacer()
            }
        }
        .padding(12)
        .background(DesignSystem.lightGray)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct SunExposureChart: View {
    let uvIndex: Int
    let animateCharts: Bool
    
    private var safeExposureTimes: [(String, Int, Color)] {
        let baseTime = max(10, 60 - (uvIndex * 5)) // Minutos seguros
        return [
            ("Piel clara", baseTime / 2, .red),
            ("Piel media", baseTime, .orange),
            ("Piel oscura", baseTime * 2, .brown),
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sun.max.fill")
                    .foregroundColor(.orange)
                Text("Tiempo Seguro al Sol")
                    .font(DesignSystem.body())
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.primaryText)
                Spacer()
                Text("UV: \(uvIndex)")
                    .font(DesignSystem.caption())
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            }
            
            VStack(spacing: 6) {
                ForEach(Array(safeExposureTimes.enumerated()), id: \.offset) { index, data in
                    HStack {
                        Text(data.0)
                            .font(.system(size: 11))
                            .foregroundColor(DesignSystem.textGray)
                            .frame(width: 70, alignment: .leading)
                        
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(DesignSystem.borderGray)
                                .frame(height: 6)
                            
                            RoundedRectangle(cornerRadius: 3)
                                .fill(data.2)
                                .frame(width: animateCharts ? CGFloat(data.1) : 0, height: 6)
                                .animation(.easeInOut(duration: 0.6).delay(Double(index) * 0.15), value: animateCharts)
                        }
                        
                        Text("\(data.1) min")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(DesignSystem.primaryText)
                            .frame(width: 40, alignment: .trailing)
                    }
                }
            }
        }
        .padding(12)
        .background(DesignSystem.lightGray)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct ExposureRiskChart: View {
    let heatIndex: HeatIndex
    let animateCharts: Bool
    
    private var riskLevels: [(String, Double, Color)] {
        switch heatIndex {
        case .safe:
            return [
                ("Bajo", 0.9, .green),
                ("Medio", 0.1, .yellow),
                ("Alto", 0.0, .red)
            ]
        case .caution:
            return [
                ("Bajo", 0.6, .green),
                ("Medio", 0.3, .yellow),
                ("Alto", 0.1, .red)
            ]
        case .warning:
            return [
                ("Bajo", 0.3, .green),
                ("Medio", 0.5, .yellow),
                ("Alto", 0.2, .red)
            ]
        case .danger:
            return [
                ("Bajo", 0.1, .green),
                ("Medio", 0.3, .yellow),
                ("Alto", 0.6, .red)
            ]
        case .extreme:
            return [
                ("Bajo", 0.0, .green),
                ("Medio", 0.2, .yellow),
                ("Alto", 0.8, .red)
            ]
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                Text("Riesgo por Exposición")
                    .font(DesignSystem.body())
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.primaryText)
                Spacer()
                Text(heatIndex.rawValue)
                    .font(DesignSystem.caption())
                    .fontWeight(.bold)
                    .foregroundColor(heatIndex.color)
            }
            
            // Gráfica circular de riesgo
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(DesignSystem.borderGray, lineWidth: 8)
                        .frame(width: 60, height: 60)
                    
                    ForEach(Array(riskLevels.enumerated()), id: \.offset) { index, risk in
                        Circle()
                            .trim(from: 0, to: animateCharts ? CGFloat(risk.1) : 0)
                            .stroke(risk.2, lineWidth: 8)
                            .frame(width: 60, height: 60)
                            .rotationEffect(.degrees(-90 + Double(index) * 120))
                            .animation(.easeInOut(duration: 1.0).delay(Double(index) * 0.2), value: animateCharts)
                    }
                    
                    Text("\(Int(riskLevels.first(where: { $0.1 > 0.5 })?.1 ?? 0 * 100))%")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(DesignSystem.primaryText)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(riskLevels, id: \.0) { risk in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(risk.2)
                                .frame(width: 8, height: 8)
                            Text(risk.0)
                                .font(.system(size: 11))
                                .foregroundColor(DesignSystem.textGray)
                            Spacer()
                            Text("\(Int(risk.1 * 100))%")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(DesignSystem.primaryText)
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(DesignSystem.lightGray)
        .clipShape(RoundedRectangle(cornerRadius: 10))
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

// MARK: - Weather Metrics Components
struct WeatherMetricsCard: View {
    let metrics: WeatherMetrics
    @State private var animateProgress = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Métricas Climáticas")
                    .font(DesignSystem.headline())
                    .foregroundColor(DesignSystem.primaryText)
                Spacer()
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(DesignSystem.primaryBlue)
                    .font(.title3)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                MetricProgressView(
                    title: "Temperatura",
                    value: "\(metrics.temperature)°C",
                    progress: metrics.temperatureProgress,
                    color: temperatureColor(metrics.temperature),
                    icon: "thermometer",
                    animateProgress: animateProgress
                )
                
                MetricProgressView(
                    title: "Humedad",
                    value: "\(metrics.humidity)%",
                    progress: metrics.humidityProgress,
                    color: humidityColor(metrics.humidity),
                    icon: "humidity.fill",
                    animateProgress: animateProgress
                )
                
                MetricProgressView(
                    title: "Índice UV",
                    value: "\(metrics.uvIndex)",
                    progress: metrics.uvProgress,
                    color: uvColor(metrics.uvIndex),
                    icon: "sun.max.fill",
                    animateProgress: animateProgress
                )
                
                MetricProgressView(
                    title: "Viento",
                    value: "\(Int(metrics.windSpeed)) km/h",
                    progress: metrics.windProgress,
                    color: DesignSystem.primaryBlue,
                    icon: "wind",
                    animateProgress: animateProgress
                )
                
                MetricProgressView(
                    title: "Calidad Aire",
                    value: airQualityText(metrics.airQuality),
                    progress: metrics.airQualityProgress,
                    color: airQualityColor(metrics.airQuality),
                    icon: "aqi.medium",
                    animateProgress: animateProgress
                )
                
                MetricProgressView(
                    title: "Visibilidad",
                    value: "\(metrics.visibility) km",
                    progress: metrics.visibilityProgress,
                    color: DesignSystem.accentBlue,
                    icon: "eye.fill",
                    animateProgress: animateProgress
                )
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).delay(0.3)) {
                animateProgress = true
            }
        }
    }
    
    private func temperatureColor(_ temp: Int) -> Color {
        switch temp {
        case ..<20: return .blue
        case 20..<30: return .green
        case 30..<35: return .orange
        default: return .red
        }
    }
    
    private func humidityColor(_ humidity: Int) -> Color {
        switch humidity {
        case ..<30: return .orange
        case 30..<70: return .green
        default: return .blue
        }
    }
    
    private func uvColor(_ uv: Int) -> Color {
        switch uv {
        case ..<3: return .green
        case 3..<6: return .yellow
        case 6..<8: return .orange
        case 8..<11: return .red
        default: return .purple
        }
    }
    
    private func airQualityColor(_ quality: Int) -> Color {
        switch quality {
        case 1: return .green
        case 2: return .yellow
        case 3: return .orange
        case 4: return .red
        default: return .purple
        }
    }
    
    private func airQualityText(_ quality: Int) -> String {
        switch quality {
        case 1: return "Excelente"
        case 2: return "Buena"
        case 3: return "Moderada"
        case 4: return "Mala"
        default: return "Peligrosa"
        }
    }
}

struct MetricProgressView: View {
    let title: String
    let value: String
    let progress: Double
    let color: Color
    let icon: String
    let animateProgress: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                    .frame(width: 12)
                
                Text(title)
                    .font(DesignSystem.caption())
                    .foregroundColor(DesignSystem.textGray)
                    .lineLimit(1)
                
                Spacer()
            }
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(DesignSystem.borderGray)
                    .frame(height: 6)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.7), color],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: animateProgress ? CGFloat(progress) * 100 : 0, height: 6)
                    .animation(.easeInOut(duration: 0.8), value: animateProgress)
            }
            .frame(maxWidth: .infinity)
            
            HStack {
                Text(value)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(DesignSystem.primaryText)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(DesignSystem.textGray)
            }
        }
        .padding(12)
        .background(DesignSystem.lightGray)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Enhanced Heat Index Message
struct HeatIndexMessageCard: View {
    let heatIndex: HeatIndex
    @State private var showDetails = false
    @State private var animateIcon = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Button(action: {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showDetails.toggle()
                }
            }) {
                HStack {
                    HStack(spacing: 12) {
                        Image(systemName: heatIndex.icon)
                            .font(.title2)
                            .foregroundColor(.white)
                            .scaleEffect(animateIcon ? 1.2 : 1.0)
                            .animation(
                                Animation.easeInOut(duration: 1.0)
                                    .repeatForever(autoreverses: true),
                                value: animateIcon
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(heatIndex.detailedMessage.title)
                                .font(DesignSystem.headline())
                                .foregroundColor(.white)
                            
                            Text("Toca para más información")
                                .font(DesignSystem.caption())
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: showDetails ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .rotationEffect(.degrees(showDetails ? 180 : 0))
                        .animation(.easeInOut(duration: 0.3), value: showDetails)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if showDetails {
                VStack(alignment: .leading, spacing: 12) {
                    Text("¿Por qué esta alerta?")
                        .font(DesignSystem.body())
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(heatIndex.detailedMessage.reason)
                        .font(DesignSystem.body())
                        .foregroundColor(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Acciones recomendadas:")
                        .font(DesignSystem.body())
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.top, 8)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(Array(heatIndex.detailedMessage.actions.enumerated()), id: \.offset) { index, action in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                    .font(DesignSystem.body())
                                    .foregroundColor(.white)
                                
                                Text(action)
                                    .font(DesignSystem.body())
                                    .foregroundColor(.white.opacity(0.9))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .opacity(showDetails ? 1 : 0)
                            .offset(x: showDetails ? 0 : -20)
                            .animation(
                                .easeInOut(duration: 0.4)
                                .delay(Double(index) * 0.1),
                                value: showDetails
                            )
                        }
                    }
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity.combined(with: .move(edge: .top))
                ))
            }
        }
        .padding(DesignSystem.padding)
        .background(
            LinearGradient(
                colors: [heatIndex.color, heatIndex.color.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.cornerRadius))
        .onAppear {
            if heatIndex == .danger || heatIndex == .extreme {
                animateIcon = true
            }
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

// MARK: - Weather Forecast Components
struct WeatherForecastCard: View {
    @ObservedObject var weatherManager: WeatherManager
    @ObservedObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Pronóstico de 5 Días")
                    .font(DesignSystem.headline())
                    .foregroundColor(DesignSystem.primaryText)
                Spacer()
                
                if weatherManager.isLoadingForecast {
                    ProgressView()
                        .scaleEffect(0.7)
                        .tint(DesignSystem.primaryBlue)
                }
            }
            
            if weatherManager.dailyForecast.isEmpty && !weatherManager.isLoadingForecast {
                VStack(spacing: 8) {
                    Image(systemName: "cloud.rain")
                        .font(.title2)
                        .foregroundColor(DesignSystem.textGray)
                    Text("Pronóstico no disponible")
                        .font(DesignSystem.caption())
                        .foregroundColor(DesignSystem.textGray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(weatherManager.dailyForecast.prefix(5)) { forecast in
                            ForecastDayCard(forecast: forecast, themeManager: themeManager)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
    }
}

struct ForecastDayCard: View {
    let forecast: DailyForecast
    @ObservedObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 8) {
            // Day name
            Text(formatDayName(forecast.dayName))
                .font(DesignSystem.caption())
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.primaryText)
            
            // Weather icon
            Image(systemName: forecast.icon)
                .font(.title2)
                .foregroundColor(DesignSystem.primaryBlue)
                .frame(height: 24)
            
            // Temperature range
            VStack(spacing: 2) {
                Text(formatTemperature(forecast.maxTemp, unit: themeManager.temperatureUnit))
                    .font(DesignSystem.body())
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.primaryText)
                
                Text(formatTemperature(forecast.minTemp, unit: themeManager.temperatureUnit))
                    .font(DesignSystem.caption())
                    .foregroundColor(DesignSystem.textGray)
            }
            
            // Heat index indicator
            HStack(spacing: 4) {
                Image(systemName: forecast.heatIndex.icon)
                    .font(.system(size: 8))
                Text(forecast.heatIndex.rawValue)
                    .font(.system(size: 9, weight: .medium))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(forecast.heatIndex.color)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            
            // Precipitation probability
            if forecast.precipitationProbability > 0 {
                HStack(spacing: 2) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 8))
                        .foregroundColor(DesignSystem.primaryBlue)
                    Text("\(forecast.precipitationProbability)%")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(DesignSystem.textGray)
                }
            }
        }
        .frame(width: 70)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(DesignSystem.lightGray)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private func formatDayName(_ dayName: String) -> String {
        if Calendar.current.isDateInToday(forecast.date) {
            return "Hoy"
        } else if Calendar.current.isDateInTomorrow(forecast.date) {
            return "Mañana"
        } else {
            return String(dayName.prefix(3))
        }
    }
    
    private func formatTemperature(_ temp: Int, unit: TemperatureUnit) -> String {
        switch unit {
        case .celsius:
            return "\(temp)°"
        case .fahrenheit:
            return "\(Int(Double(temp) * 9/5 + 32))°"
        }
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
