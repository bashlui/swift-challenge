import SwiftUI
import SwiftData
import CoreLocation

// MARK: - Main Content View (TabView + Home + SwiftData)
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var selectedTab = 0
    @StateObject private var themeManager = ThemeManager()
    
    var body: some View {
        ZStack {
            DesignSystem.lightGray.ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                HomeView(
                    selectedTab: $selectedTab,
                    themeManager: themeManager,
                    modelContext: modelContext,
                    items: items
                )
                .tabItem {
                    Label("Inicio", systemImage: "house.fill")
                }
                .tag(0)
                
                MapView()
                    .tabItem {
                        Label("Mapa", systemImage: "map.fill")
                    }
                    .tag(1)
                
                AssessmentView()
                    .tabItem {
                        Label("Mi Hogar", systemImage: "house.circle.fill")
                    }
                    .tag(2)
                
                // Nueva pestaña para gestión de datos
                DataManagementView(modelContext: modelContext, items: items)
                    .tabItem {
                        Label("Datos", systemImage: "list.bullet.clipboard")
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

// MARK: - Home View (Actualizada con SwiftData)
struct HomeView: View {
    @Binding var selectedTab: Int
    @ObservedObject var themeManager: ThemeManager
    @StateObject private var locationManager = LocationManager()
    @StateObject private var weatherManager = WeatherManager()
    @State private var showingSafetyTips = false
    
    // SwiftData properties
    let modelContext: ModelContext
    let items: [Item]
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackground()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        headerSection
                        weatherSection
                        
                        // Nueva sección de estado de datos
                        dataStatusSection
                        
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
        WeatherCard(weatherManager: weatherManager, locationManager: locationManager, themeManager: themeManager)
            .padding(.horizontal, DesignSystem.padding)
    }
    
    // Nueva sección que muestra el estado de los datos
    private var dataStatusSection: some View {
        CardView {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Estado del Sistema")
                        .font(DesignSystem.headline())
                        .foregroundColor(DesignSystem.primaryText)
                    
                    Text("\(items.count) registros guardados")
                        .font(DesignSystem.caption())
                        .foregroundColor(DesignSystem.textGray)
                }
                
                Spacer()
                
                Button(action: addNewRecord) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(DesignSystem.primaryBlue)
                }
                
                Button(action: { selectedTab = 3 }) {
                    Image(systemName: "list.bullet.clipboard")
                        .font(.title2)
                        .foregroundColor(DesignSystem.secondaryBlue)
                }
            }
        }
        .padding(.horizontal, DesignSystem.padding)
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
                    title: "Evaluar Hogar",
                    subtitle: "Análisis térmico",
                    icon: "house.circle.fill",
                    gradient: [DesignSystem.accentBlue, DesignSystem.primaryBlue]
                ) {
                    selectedTab = 2
                }
                
                QuickActionCard(
                    title: "Gestión Datos",
                    subtitle: "Ver registros",
                    icon: "list.bullet.clipboard",
                    gradient: [DesignSystem.secondaryBlue, DesignSystem.accentBlue]
                ) {
                    selectedTab = 3
                }
                
                QuickActionCard(
                    title: "Protección",
                    subtitle: "Tips de supervivencia",
                    icon: "shield.checkered",
                    gradient: [DesignSystem.darkBlue, DesignSystem.primaryBlue]
                ) {
                    showingSafetyTips = true
                }
            }
            .padding(.horizontal, DesignSystem.padding)
        }
    }
    
    private func setupLocation() {
        locationManager.requestPermission()
        if let location = locationManager.location {
            weatherManager.fetchWeather(for: location)
        }
    }
    
    private func addNewRecord() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }
}

// MARK: - Nueva Vista de Gestión de Datos
struct DataManagementView: View {
    let modelContext: ModelContext
    let items: [Item]
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackground()
                
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "list.bullet.clipboard.fill")
                            .font(.largeTitle)
                            .foregroundColor(DesignSystem.primaryBlue)
                        
                        Text("Gestión de Datos")
                            .font(DesignSystem.title2())
                            .foregroundColor(DesignSystem.primaryText)
                        
                        Text("Administra los registros del sistema")
                            .font(DesignSystem.body())
                            .foregroundColor(DesignSystem.textGray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, DesignSystem.padding)
                    
                    // Stats Card
                    CardView {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Total de Registros")
                                    .font(DesignSystem.headline())
                                    .foregroundColor(DesignSystem.primaryText)
                                
                                Text("\(items.count)")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(DesignSystem.primaryBlue)
                            }
                            
                            Spacer()
                            
                            VStack(spacing: 8) {
                                Button(action: addItem) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title)
                                        .foregroundColor(DesignSystem.primaryBlue)
                                }
                                
                                Text("Agregar")
                                    .font(DesignSystem.caption())
                                    .foregroundColor(DesignSystem.textGray)
                            }
                        }
                    }
                    .padding(.horizontal, DesignSystem.padding)
                    
                    // Lista de elementos
                    if items.isEmpty {
                        Spacer()
                        
                        VStack(spacing: 16) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 60))
                                .foregroundColor(DesignSystem.textGray.opacity(0.5))
                            
                            Text("No hay registros")
                                .font(DesignSystem.headline())
                                .foregroundColor(DesignSystem.textGray)
                            
                            Text("Agrega el primer registro presionando el botón +")
                                .font(DesignSystem.body())
                                .foregroundColor(DesignSystem.textGray)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, DesignSystem.padding)
                        
                        Spacer()
                    } else {
                        // Lista con diseño personalizado
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                                    CardView {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Registro #\(index + 1)")
                                                    .font(DesignSystem.headline())
                                                    .foregroundColor(DesignSystem.primaryText)
                                                
                                                Text(item.timestamp.formatted(date: .abbreviated, time: .shortened))
                                                    .font(DesignSystem.caption())
                                                    .foregroundColor(DesignSystem.textGray)
                                            }
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                deleteItem(item)
                                            }) {
                                                Image(systemName: "trash.circle.fill")
                                                    .font(.title2)
                                                    .foregroundColor(.red.opacity(0.7))
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, DesignSystem.padding)
                        }
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }
    
    private func deleteItem(_ item: Item) {
        withAnimation {
            modelContext.delete(item)
        }
    }
}

// MARK: - Safety Tips Sheet (Sin cambios)
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
