import SwiftUI
import CoreLocation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

// MARK: - Main Content View (TabView + Home)
struct ContentView: View {
    @State private var selectedTab = 0
    @StateObject private var themeManager = ThemeManager()
    
    var body: some View {
        ZStack {
            DesignSystem.lightGray.ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                HomeView(selectedTab: $selectedTab, themeManager: themeManager)
                    .tabItem {
                        Label("Inicio", systemImage: "house.fill")
                    }
                    .tag(0)
                
                MapView()
                    .tabItem {
                        Label("Mapa", systemImage: "map.fill")
                    }
                    .tag(1)
                
                HeatMapView()
                    .tabItem {
                        Label("Calor", systemImage: "thermometer.sun.fill")
                    }
                    .tag(2)
                
                AssessmentView()
                    .tabItem {
                        Label("Mi Hogar", systemImage: "house.circle.fill")
                    }
                    .tag(3)
                
                SettingsAlertsView(themeManager: themeManager)
                    .tabItem {
                        Label("Configuración", systemImage: "gear.circle.fill")
                    }
                    .tag(4)
            }
            .accentColor(DesignSystem.primaryBlue)
            .preferredColorScheme(colorScheme(for: themeManager.appearanceMode))
        }
        .environmentObject(themeManager)
    }
    
    private func colorScheme(for mode: AppearanceMode) -> ColorScheme? {
        switch mode {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}

// MARK: - Home View
struct HomeView: View {
    @Binding var selectedTab: Int
    @ObservedObject var themeManager: ThemeManager
    @StateObject private var locationManager = LocationManager()
    @StateObject private var weatherManager = WeatherManager()
    @State private var showingSafetyTips = false
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackground()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        headerSection
                        weatherSection
                        quickActionsSection
                        Spacer(minLength: 20)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .refreshable {
                if let location = locationManager.location {
                    weatherManager.fetchWeather(for: location)
                    weatherManager.fetchForecast(for: location)
                }
            }
            .sheet(isPresented: $showingSafetyTips) {
                SafetyTipsSheet()
            }
        }
        .onAppear {
            setupLocation()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "shield.fill")
                    .font(.largeTitle)
                    .foregroundColor(DesignSystem.primaryBlue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("HeatShield")
                        .font(DesignSystem.title1())
                        .foregroundColor(DesignSystem.primaryText)
                    
                    Text("Protección Inteligente contra el Calor Extremo")
                        .font(DesignSystem.caption())
                        .foregroundColor(DesignSystem.textGray)
                }
                
                Spacer()
            }
            .padding(.horizontal, DesignSystem.padding)
            .padding(.top, 8)
        }
    }
    
    private var weatherSection: some View {
        VStack(spacing: 16) {
            WeatherCard(weatherManager: weatherManager, locationManager: locationManager, themeManager: themeManager)
                .padding(.horizontal, DesignSystem.padding)
            
            // Nueva sección de pronóstico
            CardView {
                WeatherForecastCard(weatherManager: weatherManager, themeManager: themeManager)
            }
            .padding(.horizontal, DesignSystem.padding)
        }
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Acciones Rápidas")
                    .font(DesignSystem.headline())
                    .foregroundColor(DesignSystem.primaryText)
                Spacer()
            }
            .padding(.horizontal, DesignSystem.padding)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                QuickActionCard(
                    title: "Zonas Frescas",
                    subtitle: "Refugios cercanos",
                    icon: "map.fill",
                    gradient: [DesignSystem.primaryBlue, DesignSystem.secondaryBlue]
                ) {
                    selectedTab = 1
                }
                
                QuickActionCard(
                    title: "Mapa de Calor",
                    subtitle: "Vista térmica",
                    icon: "thermometer.sun.fill",
                    gradient: [.orange, .red]
                ) {
                    selectedTab = 2
                }
                
                QuickActionCard(
                    title: "Evaluar Hogar",
                    subtitle: "Análisis térmico",
                    icon: "house.circle.fill",
                    gradient: [DesignSystem.accentBlue, DesignSystem.primaryBlue]
                ) {
                    selectedTab = 3
                }
                
                QuickActionCard(
                    title: "Configuración",
                    subtitle: "Alertas y ajustes",
                    icon: "gear.circle.fill",
                    gradient: [DesignSystem.secondaryBlue, DesignSystem.accentBlue]
                ) {
                    selectedTab = 4
                }
                
                QuickActionCard(
                    title: "Protección",
                    subtitle: "Tips de supervivencia",
                    icon: "shield.checkered",
                    gradient: [DesignSystem.darkBlue, DesignSystem.primaryBlue]
                ) {
                    showingSafetyTips = true
                }
                
                // Espacio para mantener el grid equilibrado
                Color.clear
                    .frame(height: 0)
            }
            .padding(.horizontal, DesignSystem.padding)
        }
    }
    
    private func setupLocation() {
        locationManager.requestPermission()
        if let location = locationManager.location {
            weatherManager.fetchWeather(for: location)
            weatherManager.fetchForecast(for: location)
        }
    }
}

// MARK: - Safety Tips Sheet
struct SafetyTipsSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let tips = [
        ("💧", "Hidratación constante cada 15-20 minutos", "Bebe agua aunque no tengas sed. En calor extremo, necesitas 250-300ml cada 15-20 minutos."),
        ("🌳", "Búsqueda activa de áreas sombreadas", "La sombra puede reducir la temperatura hasta 15°C. Busca árboles, toldos o estructuras."),
        ("👕", "Vestimenta ligera en tonos claros", "Usa ropa de algodón o materiales transpirables en colores blancos o claros que reflejen el calor."),
        ("⏰", "Evitar exposición 12:00 - 16:00 hrs", "Las horas de mayor radiación solar. Si debes salir, usa protección extra."),
        ("🧴", "Protección solar cada 2 horas", "Usa factor 30+ y reaplica frecuentemente, especialmente después de sudar."),
        ("❄️", "Toallas húmedas en puntos de pulso", "Aplica en cuello, muñecas y sienes para enfriar la sangre que va al cerebro."),
        ("🏠", "Crear corrientes de aire en casa", "Abre ventanas opuestas durante las horas frescas para crear ventilación cruzada."),
        ("🚗", "Nunca dejes personas/mascotas en vehículos", "Un auto puede alcanzar 60°C en 20 minutos, incluso con ventanas abiertas.")
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackground()
                
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(spacing: 12) {
                            Image(systemName: "shield.checkered")
                                .font(.largeTitle)
                                .foregroundColor(DesignSystem.primaryBlue)
                            
                            Text("Protección Térmica")
                                .font(DesignSystem.title1())
                                .foregroundColor(DesignSystem.primaryText)
                            
                            Text("Guía completa para protegerte del calor extremo")
                                .font(DesignSystem.body())
                                .foregroundColor(DesignSystem.textGray)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, DesignSystem.padding)
                        
                        ForEach(Array(tips.enumerated()), id: \.offset) { index, tip in
                            CardView {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack(spacing: 12) {
                                        Text(tip.0)
                                            .font(.title2)
                                        
                                        Text(tip.1)
                                            .font(DesignSystem.headline())
                                            .foregroundColor(DesignSystem.primaryText)
                                            .multilineTextAlignment(.leading)
                                        
                                        Spacer()
                                    }
                                    
                                    Text(tip.2)
                                        .font(DesignSystem.body())
                                        .foregroundColor(DesignSystem.textGray)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                            .padding(.horizontal, DesignSystem.padding)
                        }
                        
                        Spacer(minLength: 20)
                    }
                }
            }
            .navigationTitle("Protección Térmica")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }
}

struct CoolZoneManager {
    static let coolZones: [CoolZone] = [
        CoolZone(name: "Biblioteca Central", type: .library,
                 coordinate: CLLocationCoordinate2D(latitude: 25.6866, longitude: -100.3161),
                 isOpen24Hours: false, description: ""),
        CoolZone(name: "Plaza Fiesta San Agustín", type: .mall,
                 coordinate: CLLocationCoordinate2D(latitude: 25.6785, longitude: -100.3099),
                 isOpen24Hours: false, description: ""),
        CoolZone(name: "Hospital Universitario", type: .hospital,
                 coordinate: CLLocationCoordinate2D(latitude: 25.6947, longitude: -100.3143),
                 isOpen24Hours: true, description: ""),
        CoolZone(name: "Parque Fundidora", type: .park,
                 coordinate: CLLocationCoordinate2D(latitude: 25.6782, longitude: -100.2836),
                 isOpen24Hours: true, description: ""),
        CoolZone(name: "Centro Comunitario Independencia", type: .community,
                 coordinate: CLLocationCoordinate2D(latitude: 25.6945, longitude: -100.3234),
                 isOpen24Hours: false, description: "")
    ]
    
    static func nearestCoolZone(from userLocation: CLLocation) -> CoolZone? {
        return coolZones.min { zone1, zone2 in
            let dist1 = userLocation.distance(from: CLLocation(latitude: zone1.coordinate.latitude, longitude: zone1.coordinate.longitude))
            let dist2 = userLocation.distance(from: CLLocation(latitude: zone2.coordinate.latitude, longitude: zone2.coordinate.longitude))
            return dist1 < dist2
        }
    }
}


import AppIntents

struct NearbyCoolZoneIntent: AppIntent {
    static var title: LocalizedStringResource = "Buscar zona fresca cercana"
    
    static var description = IntentDescription("Encuentra la zona fresca más cercana disponible.")

    static var parameterSummary: some ParameterSummary {
        Summary("Buscar zona fresca cercana")
    }

    func perform() async throws -> some ProvidesDialog {
        let locationManager = CLLocationManager()
        guard let location = locationManager.location else {
            return .result(dialog: IntentDialog("No se pudo obtener tu ubicación."))
        }
        
        guard let nearest = CoolZoneManager.nearestCoolZone(from: location) else {
            return .result(dialog: IntentDialog("No se encontraron zonas frescas cerca de ti."))
        }
        
        let name = nearest.name
        let distance = location.distance(from: CLLocation(latitude: nearest.coordinate.latitude, longitude: nearest.coordinate.longitude)) / 1000
        let open = nearest.isOpen24Hours

        let response = "📍 \(name) está a \(String(format: "%.1f", distance)) km. " + (open ? "Está abierto 24h." : "Actualmente cerrado.")
        return .result(dialog: IntentDialog(stringLiteral: response))
    }

}

extension NearbyCoolZoneIntent: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: NearbyCoolZoneIntent(),
            phrases: [
                "Encuentra zona fresca con \(.applicationName)",
                "Buscar sombra cerca usando \(.applicationName)",
                "Zona fresca cercana en \(.applicationName)"
            ],
            shortTitle: "Zona Fresca",
            systemImageName: "leaf"
        )
    }
}
