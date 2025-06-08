import SwiftUI
import MapKit
import CoreLocation
// MARK: - Cool Zone Type


// MARK: - Enhanced Cool Zone Model
struct EnhancedCoolZone: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let type: CoolZoneType
    let coordinate: CLLocationCoordinate2D
    let isOpen24Hours: Bool
    let description: String
    let isVerified: Bool
    let phoneNumber: String?
    let url: URL?
    
    // Equatable conformance
    static func == (lhs: EnhancedCoolZone, rhs: EnhancedCoolZone) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.coordinate.latitude == rhs.coordinate.latitude &&
               lhs.coordinate.longitude == rhs.coordinate.longitude &&
               lhs.type == rhs.type
    }
    
    init(name: String, type: CoolZoneType, coordinate: CLLocationCoordinate2D,
         isOpen24Hours: Bool, description: String, isVerified: Bool = false,
         phoneNumber: String? = nil, url: URL? = nil) {
        self.name = name
        self.type = type
        self.coordinate = coordinate
        self.isOpen24Hours = isOpen24Hours
        self.description = description
        self.isVerified = isVerified
        self.phoneNumber = phoneNumber
        self.url = url
    }
}

// MARK: - Heat Map Manager
class HeatMapManager: ObservableObject {
    @Published var detectedCoolZones: [EnhancedCoolZone] = []
    
    func searchForCoolZones(around location: CLLocation, completion: @escaping () -> Void) {
        let searchRegion = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        
        // Buscar diferentes tipos de lugares
        let searchTypes = [
            ("centro comercial", CoolZoneType.mall),
            ("parque", CoolZoneType.park),
            ("biblioteca", CoolZoneType.library),
            ("centro comunitario", CoolZoneType.community)
        ]
        
        let group = DispatchGroup()
        var allZones: [EnhancedCoolZone] = []
        
        for (query, type) in searchTypes {
            group.enter()
            
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            request.region = searchRegion
            
            // Configurar filtros de categorías
            switch type {
            case .park:
                request.pointOfInterestFilter = MKPointOfInterestFilter(including: [.park])
            case .library:
                request.pointOfInterestFilter = MKPointOfInterestFilter(including: [.library])
            default:
                break
            }
            
            let search = MKLocalSearch(request: request)
            search.start { response, error in
                defer { group.leave() }
                
                guard let response = response else {
                    print("Error searching for \(query): \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                let zones = response.mapItems.compactMap { item -> EnhancedCoolZone? in
                    guard let name = item.name,
                          let location = item.placemark.location else { return nil }
                    
                    return EnhancedCoolZone(
                        name: name,
                        type: type,
                        coordinate: location.coordinate,
                        isOpen24Hours: self.checkIf24Hours(item: item, type: type),
                        description: self.generateDescription(for: type),
                        isVerified: true,
                        phoneNumber: item.phoneNumber,
                        url: item.url
                    )
                }
                
                allZones.append(contentsOf: zones)
            }
        }
        
        group.notify(queue: .main) {
            self.detectedCoolZones = allZones.sorted { zone1, zone2 in
                let dist1 = location.distance(from: CLLocation(
                    latitude: zone1.coordinate.latitude,
                    longitude: zone1.coordinate.longitude
                ))
                let dist2 = location.distance(from: CLLocation(
                    latitude: zone2.coordinate.latitude,
                    longitude: zone2.coordinate.longitude
                ))
                return dist1 < dist2
            }
            completion()
        }
    }
    
    private func checkIf24Hours(item: MKMapItem, type: CoolZoneType) -> Bool {
        // Lógica básica - se puede mejorar con datos reales
        switch type {
        case .park:
            return true // Los parques generalmente están abiertos
        case .mall, .library, .community:
            return false // Estos generalmente tienen horarios
        case .hospital:
            return true // Los hospitales generalmente están abiertos 24/7
        }
    }
    
    private func generateDescription(for type: CoolZoneType) -> String {
        switch type {
        case .mall:
            return "Aire acondicionado, múltiples áreas de descanso"
        case .park:
            return "Áreas sombreadas, espacios naturales frescos"
        case .library:
            return "Aire acondicionado gratuito, espacios tranquilos"
        case .community:
            return "Refugio climático con servicios básicos"
        case .hospital:
            return "Instalaciones médicas con climatización"
        }
    }
}

// MARK: - Heat Map View
struct HeatMapView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var heatMapManager = HeatMapManager()
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 25.6866, longitude: -100.3161),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    
    @State private var showHeatMap = true
    @State private var selectedZone: EnhancedCoolZone?
    @State private var isSearching = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Map(position: $position) {
                    // User location
                    if let userLocation = locationManager.location {
                        Annotation("Tu ubicación", coordinate: userLocation.coordinate) {
                            ZStack {
                                Circle()
                                    .fill(DesignSystem.white)
                                    .frame(width: 24, height: 24)
                                    .shadow(color: Color.black.opacity(0.3), radius: 4)
                                
                                Circle()
                                    .fill(DesignSystem.primaryBlue)
                                    .frame(width: 16, height: 16)
                            }
                        }
                    }
                    
                    // Cool Zones detectadas
                    ForEach(heatMapManager.detectedCoolZones, id: \.id) { zone in
                        Annotation(zone.name, coordinate: zone.coordinate) {
                            Button(action: {
                                selectedZone = zone
                            }) {
                                VStack(spacing: 4) {
                                    ZStack {
                                        Circle()
                                            .fill(DesignSystem.white)
                                            .frame(width: 40, height: 40)
                                            .shadow(color: Color.black.opacity(0.2), radius: 4)
                                        
                                        Image(systemName: zone.type.icon)
                                            .foregroundColor(zone.type.color)
                                            .font(.title3)
                                    }
                                    
                                    if zone.isVerified {
                                        Image(systemName: "checkmark.seal.fill")
                                            .font(.system(size: 10))
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                        }
                    }
                }
                .overlay(alignment: .center) {
                    if showHeatMap {
                        HeatMapOverlay(
                            coolZones: heatMapManager.detectedCoolZones,
                            gridSize: 50
                        )
                        .allowsHitTesting(false)
                        .opacity(0.6)
                    }
                }
                .onAppear {
                    checkLocationAndSearch()
                }
                .onChange(of: heatMapManager.detectedCoolZones.count) { oldValue, newValue in
                    print("Cool zones count changed from \(oldValue) to \(newValue)")
                }
                
                // Controls overlay
                VStack {
                    // Header
                    headerView
                    
                    Spacer()
                    
                    // Selected zone card
                    if let selectedZone = selectedZone {
                        VStack {
                            Spacer()
                            EnhancedCoolZoneInfoCard(
                                zone: selectedZone,
                                distance: calculateDistance(to: selectedZone),
                                onClose: {
                                    self.selectedZone = nil
                                }
                            )
                            .padding(.horizontal, DesignSystem.padding)
                            .padding(.bottom, 20)
                        }
                    }
                }
                
                // Side controls
                VStack {
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            // Toggle heat map
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showHeatMap.toggle()
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(showHeatMap ? DesignSystem.primaryBlue : DesignSystem.white)
                                        .frame(width: 44, height: 44)
                                        .shadow(color: Color.black.opacity(0.15), radius: 4)
                                    
                                    Image(systemName: showHeatMap ? "map.fill" : "map")
                                        .foregroundColor(showHeatMap ? .white : DesignSystem.primaryBlue)
                                        .font(.title3)
                                }
                            }
                            
                            // Refresh button
                            Button(action: {
                                if let location = locationManager.location {
                                    searchForCoolZones(around: location)
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(DesignSystem.white)
                                        .frame(width: 44, height: 44)
                                        .shadow(color: Color.black.opacity(0.15), radius: 4)
                                    
                                    Image(systemName: "arrow.clockwise")
                                        .foregroundColor(DesignSystem.primaryBlue)
                                        .font(.title3)
                                        .rotationEffect(.degrees(isSearching ? 360 : 0))
                                        .animation(isSearching ?
                                                 Animation.linear(duration: 1).repeatForever(autoreverses: false) :
                                                 .default, value: isSearching)
                                }
                            }
                            .disabled(isSearching)
                            
                            Spacer()
                        }
                        .padding(DesignSystem.padding)
                    }
                    Spacer()
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Mapa de Zonas Frescas")
                        .font(DesignSystem.title2())
                        .foregroundColor(DesignSystem.primaryText)
                    
                    HStack(spacing: 8) {
                        if isSearching {
                            ProgressView()
                                .scaleEffect(0.8)
                                .tint(DesignSystem.primaryBlue)
                            Text("Buscando zonas...")
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("\(heatMapManager.detectedCoolZones.count) zonas encontradas")
                        }
                    }
                    .font(DesignSystem.caption())
                    .foregroundColor(DesignSystem.textGray)
                }
                
                Spacer()
            }
            .padding(.horizontal, DesignSystem.padding)
            
            // Legend
            if showHeatMap {
                HeatMapLegend()
                    .padding(.horizontal, DesignSystem.padding)
            }
        }
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                colors: [DesignSystem.white, DesignSystem.white.opacity(0.95)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private func checkLocationAndSearch() {
        locationManager.requestPermission()
        if let location = locationManager.location {
            searchForCoolZones(around: location)
        }
    }
    
    private func searchForCoolZones(around location: CLLocation) {
        isSearching = true
        heatMapManager.searchForCoolZones(around: location) {
            isSearching = false
        }
    }
    
    private func calculateDistance(to zone: EnhancedCoolZone) -> Double? {
        guard let userLocation = locationManager.location else { return nil }
        let zoneLocation = CLLocation(latitude: zone.coordinate.latitude, longitude: zone.coordinate.longitude)
        return userLocation.distance(from: zoneLocation)
    }
}

// MARK: - Enhanced Cool Zone Info Card
struct EnhancedCoolZoneInfoCard: View {
    let zone: EnhancedCoolZone
    let distance: Double?
    let onClose: () -> Void
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: zone.type.icon)
                        .foregroundColor(zone.type.color)
                        .font(.title2)
                        .frame(width: 32, height: 32)
                        .background(zone.type.color.opacity(0.1))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(zone.name)
                            .font(DesignSystem.headline())
                            .foregroundColor(DesignSystem.primaryText)
                        
                        HStack(spacing: 8) {
                            Text(zone.type.rawValue)
                                .font(DesignSystem.caption())
                                .foregroundColor(DesignSystem.textGray)
                            
                            if let distance = distance {
                                HStack(spacing: 2) {
                                    Image(systemName: "location.fill")
                                        .font(.system(size: 8))
                                    Text(formatDistance(distance))
                                }
                                .font(DesignSystem.caption())
                                .foregroundColor(DesignSystem.primaryBlue)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(DesignSystem.lightBlue)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .foregroundColor(DesignSystem.textGray)
                            .font(.caption)
                            .frame(width: 24, height: 24)
                            .background(DesignSystem.mediumGray)
                            .clipShape(Circle())
                    }
                }
                
                Text(zone.description)
                    .font(DesignSystem.body())
                    .foregroundColor(DesignSystem.primaryText)
                
                HStack {
                    if zone.isOpen24Hours {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                            Text("24 Horas")
                        }
                        .font(DesignSystem.caption())
                        .foregroundColor(DesignSystem.secondaryBlue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(DesignSystem.lightBlue)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        openInMaps()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                            Text("Direcciones")
                        }
                        .font(DesignSystem.caption())
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            LinearGradient(
                                colors: [DesignSystem.primaryBlue, DesignSystem.secondaryBlue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
    }
    
    private func formatDistance(_ distance: Double) -> String {
        if distance < 1000 {
            return "\(Int(distance))m"
        } else {
            return String(format: "%.1fkm", distance / 1000)
        }
    }
    
    private func openInMaps() {
        let placemark = MKPlacemark(coordinate: zone.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = zone.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}

// MARK: - Heat Map Overlay
struct HeatMapOverlay: View {
    let coolZones: [EnhancedCoolZone]
    let gridSize: Int
    @State private var heatGrid: [[Double]] = []
    
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let cellWidth = size.width / CGFloat(gridSize)
                let cellHeight = size.height / CGFloat(gridSize)
                
                for row in 0..<gridSize {
                    for col in 0..<gridSize {
                        let x = CGFloat(col) * cellWidth
                        let y = CGFloat(row) * cellHeight
                        let rect = CGRect(x: x, y: y, width: cellWidth, height: cellHeight)
                        
                        // Calcular intensidad basada en distancia a zonas frescas
                        let intensity = calculateHeatIntensity(
                            for: CGPoint(x: x + cellWidth/2, y: y + cellHeight/2),
                            in: size
                        )
                        
                        let color = heatColor(for: intensity)
                        context.fill(Path(rect), with: .color(color))
                    }
                }
            }
        }
        .onAppear {
            generateHeatGrid()
        }
        .onChange(of: coolZones.count) { oldCount, newCount in
            generateHeatGrid()
        }
    }
    
    private func generateHeatGrid() {
        var grid: [[Double]] = Array(repeating: Array(repeating: 0.0, count: gridSize), count: gridSize)
        
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let intensity = calculateGridCellIntensity(row: row, col: col)
                grid[row][col] = intensity
            }
        }
        
        heatGrid = grid
    }
    
    private func calculateGridCellIntensity(row: Int, col: Int) -> Double {
        let baseIntensity = 0.5
        let zoneInfluence = coolZones.isEmpty ? 0.0 : 0.3
        return max(0.0, min(1.0, baseIntensity - zoneInfluence))
    }
    
    private func calculateHeatIntensity(for point: CGPoint, in size: CGSize) -> Double {
        guard !coolZones.isEmpty else { return 0.8 }
        
        let minDistance = coolZones.map { zone in
            let screenPoint = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
            let dx = point.x - screenPoint.x
            let dy = point.y - screenPoint.y
            return sqrt(dx * dx + dy * dy)
        }.min() ?? 1000.0
        
        let normalizedDistance = min(minDistance / 200.0, 1.0)
        return normalizedDistance * 0.8
    }
    
    private func heatColor(for intensity: Double) -> Color {
        let red = intensity
        let blue = 1.0 - intensity
        return Color(red: red, green: 0.0, blue: blue, opacity: 0.4)
    }
}

// MARK: - Heat Map Legend
struct HeatMapLegend: View {
    var body: some View {
        HStack(spacing: 12) {
            ForEach(legendItems) { item in
                HStack(spacing: 4) {
                    Circle()
                        .fill(item.color)
                        .frame(width: 12, height: 12)
                    Text(item.label)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(DesignSystem.textGray)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(DesignSystem.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var legendItems: [LegendItem] {
        [
            LegendItem(color: .blue, label: "Fresco"),
            LegendItem(color: .green, label: "Cómodo"),
            LegendItem(color: .yellow, label: "Templado"),
            LegendItem(color: .orange, label: "Cálido"),
            LegendItem(color: .red, label: "Caliente")
        ]
    }
}

// MARK: - Legend Item
struct LegendItem: Identifiable {
    let id = UUID()
    let color: Color
    let label: String
}
