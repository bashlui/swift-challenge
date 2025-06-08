//
//  MapView.swift
//  prueba-shield
//
//  Created by Alumno on 08/06/25.
//

import SwiftUI
import MapKit
import CoreLocation

// MARK: - Map View
struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 25.6866, longitude: -100.3161),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    
    @State private var selectedZone: CoolZone?
    @State private var showingLocationPrompt = false
    
    let coolSpots = [
        CoolZone(name: "Biblioteca Central", type: .library,
                coordinate: CLLocationCoordinate2D(latitude: 25.6866, longitude: -100.3161),
                isOpen24Hours: false, description: "Aire acondicionado gratuito, agua disponible"),
        CoolZone(name: "Plaza Fiesta San Agustín", type: .mall,
                coordinate: CLLocationCoordinate2D(latitude: 25.6785, longitude: -100.3099),
                isOpen24Hours: false, description: "Centro comercial con múltiples áreas frescas"),
        CoolZone(name: "Hospital Universitario", type: .hospital,
                coordinate: CLLocationCoordinate2D(latitude: 25.6947, longitude: -100.3143),
                isOpen24Hours: true, description: "Área de emergencias disponible 24/7"),
        CoolZone(name: "Parque Fundidora", type: .park,
                coordinate: CLLocationCoordinate2D(latitude: 25.6782, longitude: -100.2836),
                isOpen24Hours: true, description: "Áreas sombreadas y fuentes de agua"),
        CoolZone(name: "Centro Comunitario Independencia", type: .community,
                coordinate: CLLocationCoordinate2D(latitude: 25.6945, longitude: -100.3234),
                isOpen24Hours: false, description: "Refugio climático autorizado")
    ]
    
    var sortedCoolSpots: [CoolZone] {
        if locationManager.location != nil {
            return coolSpots.sorted { zone1, zone2 in
                let distance1 = locationManager.distanceToZone(zone1) ?? Double.infinity
                let distance2 = locationManager.distanceToZone(zone2) ?? Double.infinity
                return distance1 < distance2
            }
        }
        return coolSpots
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Map(position: $position) {
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
                                
                                Circle()
                                    .stroke(DesignSystem.white, lineWidth: 2)
                                    .frame(width: 16, height: 16)
                            }
                        }
                    }
                    
                    ForEach(sortedCoolSpots) { spot in
                        Annotation(spot.name, coordinate: spot.coordinate) {
                            Button(action: {
                                selectedZone = spot
                            }) {
                                VStack(spacing: 4) {
                                    ZStack {
                                        Circle()
                                            .fill(DesignSystem.white)
                                            .frame(width: 44, height: 44)
                                            .shadow(color: Color.black.opacity(0.2), radius: 4)
                                        
                                        Image(systemName: spot.type.icon)
                                            .foregroundColor(spot.type.color)
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                        
                                        if let distance = locationManager.distanceToZone(spot) {
                                            VStack {
                                                Spacer()
                                                Text(formatDistance(distance))
                                                    .font(.system(size: 8, weight: .bold))
                                                    .foregroundColor(.white)
                                                    .padding(2)
                                                    .background(DesignSystem.primaryBlue)
                                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                                    .offset(y: 28)
                                            }
                                        }
                                    }
                                    
                                    if spot.isOpen24Hours {
                                        Text("24h")
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(2)
                                            .background(DesignSystem.secondaryBlue)
                                            .clipShape(RoundedRectangle(cornerRadius: 4))
                                    }
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    checkLocationPermission()
                }
                .onChange(of: locationManager.location) { oldValue, newValue in
                    if let location = newValue {
                        position = MapCameraPosition.region(
                            MKCoordinateRegion(
                                center: location.coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                            )
                        )
                    }
                }
                
                if let zone = selectedZone {
                    VStack {
                        Spacer()
                        CoolZoneInfoCard(
                            zone: zone,
                            distance: locationManager.distanceToZone(zone)
                        ) {
                            selectedZone = nil
                        }
                        .padding(DesignSystem.padding)
                    }
                }
                
                VStack {
                    HStack {
                        Spacer()
                        VStack {
                            Button(action: {
                                if locationManager.authorizationStatus == .notDetermined {
                                    locationManager.requestPermission()
                                } else if locationManager.authorizationStatus == .denied {
                                    showingLocationPrompt = true
                                } else {
                                    locationManager.startLocationUpdates()
                                }
                            }) {
                                Image(systemName: locationManager.isLoading ? "location.fill" : "location")
                                    .foregroundColor(DesignSystem.primaryBlue)
                                    .font(.title3)
                                    .frame(width: 44, height: 44)
                                    .background(DesignSystem.white)
                                    .clipShape(Circle())
                                    .shadow(color: Color.black.opacity(0.15), radius: 4)
                            }
                            .rotationEffect(.degrees(locationManager.isLoading ? 360 : 0))
                            .animation(locationManager.isLoading ?
                                      Animation.linear(duration: 1).repeatForever(autoreverses: false) :
                                      .default, value: locationManager.isLoading)
                            
                            Spacer()
                        }
                        .padding(DesignSystem.padding)
                    }
                    Spacer()
                }
                
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Zonas Frescas")
                                .font(DesignSystem.title2())
                                .foregroundColor(DesignSystem.primaryText)
                            
                            if locationManager.location != nil {
                                Text("\(sortedCoolSpots.count) lugares cerca de ti")
                                    .font(DesignSystem.caption())
                                    .foregroundColor(DesignSystem.textGray)
                            } else {
                                Text("Activar ubicación para distancias")
                                    .font(DesignSystem.caption())
                                    .foregroundColor(DesignSystem.textGray)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(DesignSystem.padding)
                    .background(
                        LinearGradient(
                            colors: [DesignSystem.white, DesignSystem.white.opacity(0.9)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    Spacer()
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .alert("Ubicación Requerida", isPresented: $showingLocationPrompt) {
                Button("Configuración") {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                }
                Button("Cancelar", role: .cancel) { }
            } message: {
                Text("Ve a Configuración > Privacidad > Servicios de Localización para permitir el acceso.")
            }
        }
    }
    
    private func checkLocationPermission() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestPermission()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startLocationUpdates()
        default:
            break
        }
    }
    
    private func formatDistance(_ distance: Double) -> String {
        if distance < 1000 {
            return "\(Int(distance))m"
        } else {
            return String(format: "%.1fkm", distance / 1000)
        }
    }
}

// MARK: - Cool Zone Info Card
struct CoolZoneInfoCard: View {
    let zone: CoolZone
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
