//
//  SettingsAlerts.swift
//  prueba-shield
//
//  Created by Alumno on 08/06/25.
//

import SwiftUI
import UserNotifications

// MARK: - Settings & Alerts Combined View
struct SettingsAlertsView: View {
    @ObservedObject var themeManager: ThemeManager
    @State private var selectedSection = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackground()
                
                VStack(spacing: 0) {
                    // Header
                    headerSection
                    
                    // Section Picker
                    sectionPicker
                    
                    // Content
                    TabView(selection: $selectedSection) {
                        SettingsContent(themeManager: themeManager)
                            .tag(0)
                        
                        AlertsContent(themeManager: themeManager)
                            .tag(1)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: selectedSection == 0 ? "gear.circle.fill" : "bell.circle.fill")
                .font(.largeTitle)
                .foregroundColor(DesignSystem.primaryBlue)
            
            Text(selectedSection == 0 ? "Configuración" : "Sistema de Alertas")
                .font(DesignSystem.title2())
                .foregroundColor(DesignSystem.primaryText)
            
            Text(selectedSection == 0 ? "Personaliza tu experiencia HeatShield" : "Configuración personalizada de notificaciones")
                .font(DesignSystem.body())
                .foregroundColor(DesignSystem.textGray)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
        .padding(.horizontal, DesignSystem.padding)
    }
    
    private var sectionPicker: some View {
        HStack(spacing: 0) {
            Button(action: { selectedSection = 0 }) {
                HStack(spacing: 8) {
                    Image(systemName: "gear.fill")
                    Text("Configuración")
                        .fontWeight(.medium)
                }
                .font(DesignSystem.body())
                .foregroundColor(selectedSection == 0 ? .white : DesignSystem.primaryBlue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(selectedSection == 0 ? DesignSystem.primaryBlue : Color.clear)
                )
            }
            
            Button(action: { selectedSection = 1 }) {
                HStack(spacing: 8) {
                    Image(systemName: "bell.fill")
                    Text("Alertas")
                        .fontWeight(.medium)
                }
                .font(DesignSystem.body())
                .foregroundColor(selectedSection == 1 ? .white : DesignSystem.primaryBlue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(selectedSection == 1 ? DesignSystem.primaryBlue : Color.clear)
                )
            }
        }
        .padding(4)
        .background(DesignSystem.lightGray)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, DesignSystem.padding)
        .padding(.vertical, 16)
    }
}

// MARK: - Settings Content
struct SettingsContent: View {
    @ObservedObject var themeManager: ThemeManager
    @State private var showingAbout = false
    @State private var showingPrivacy = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Appearance Section
                settingsSection(title: "Apariencia", icon: "paintbrush.fill") {
                    VStack(spacing: 16) {
                        appearancePicker
                        temperatureUnitPicker
                    }
                }
                
                // Notifications Section
                settingsSection(title: "Notificaciones", icon: "bell.fill") {
                    VStack(spacing: 16) {
                        notificationToggle
                        soundToggle
                        hapticToggle
                    }
                }
                
                // About Section
                settingsSection(title: "Información", icon: "info.circle.fill") {
                    VStack(spacing: 12) {
                        aboutButton
                        privacyButton
                        versionInfo
                    }
                }
                
                Spacer(minLength: 20)
            }
        }
        .sheet(isPresented: $showingAbout) {
            AboutSheet()
        }
        .sheet(isPresented: $showingPrivacy) {
            PrivacySheet()
        }
    }
    
    private func settingsSection<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(DesignSystem.primaryBlue)
                    Text(title)
                        .font(DesignSystem.headline())
                        .foregroundColor(DesignSystem.primaryText)
                    Spacer()
                }
                
                content()
            }
        }
        .padding(.horizontal, DesignSystem.padding)
    }
    
    private var appearancePicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Modo de apariencia")
                .font(DesignSystem.body())
                .foregroundColor(DesignSystem.primaryText)
            
            HStack(spacing: 0) {
                ForEach(AppearanceMode.allCases, id: \.self) { mode in
                    Button(action: {
                        themeManager.appearanceMode = mode
                        themeManager.saveSettings()
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: mode.systemName)
                                .font(.title2)
                                .foregroundColor(themeManager.appearanceMode == mode ? .white : DesignSystem.primaryBlue)
                            
                            Text(mode.displayName)
                                .font(DesignSystem.caption())
                                .fontWeight(.medium)
                                .foregroundColor(themeManager.appearanceMode == mode ? .white : DesignSystem.primaryText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(themeManager.appearanceMode == mode ?
                                      LinearGradient(colors: [DesignSystem.primaryBlue, DesignSystem.secondaryBlue],
                                                   startPoint: .topLeading, endPoint: .bottomTrailing) :
                                      LinearGradient(colors: [DesignSystem.white], startPoint: .top, endPoint: .bottom))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(themeManager.appearanceMode == mode ? Color.clear : DesignSystem.borderGray, lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if mode != AppearanceMode.allCases.last {
                        Spacer()
                            .frame(width: 8)
                    }
                }
            }
        }
    }
    
    private var temperatureUnitPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Unidad de temperatura")
                .font(DesignSystem.body())
                .foregroundColor(DesignSystem.primaryText)
            
            HStack(spacing: 8) {
                ForEach(TemperatureUnit.allCases, id: \.self) { unit in
                    Button(action: {
                        themeManager.temperatureUnit = unit
                        themeManager.saveSettings()
                    }) {
                        HStack(spacing: 6) {
                            Text(unit.symbol)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(themeManager.temperatureUnit == unit ? .white : DesignSystem.primaryBlue)
                            
                            Text(unit.displayName)
                                .font(DesignSystem.body())
                                .fontWeight(.medium)
                                .foregroundColor(themeManager.temperatureUnit == unit ? .white : DesignSystem.primaryText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(themeManager.temperatureUnit == unit ?
                                      LinearGradient(colors: [DesignSystem.accentBlue, DesignSystem.primaryBlue],
                                                   startPoint: .leading, endPoint: .trailing) :
                                      LinearGradient(colors: [DesignSystem.white], startPoint: .top, endPoint: .bottom))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(themeManager.temperatureUnit == unit ? Color.clear : DesignSystem.borderGray, lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private var notificationToggle: some View {
        Toggle(isOn: $themeManager.notificationsEnabled) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Notificaciones de emergencia")
                    .font(DesignSystem.body())
                    .foregroundColor(DesignSystem.primaryText)
                Text("Alertas de calor extremo y consejos de seguridad")
                    .font(DesignSystem.caption())
                    .foregroundColor(DesignSystem.textGray)
            }
        }
        .tint(DesignSystem.primaryBlue)
        .onChange(of: themeManager.notificationsEnabled) { _, _ in
            themeManager.saveSettings()
        }
    }
    
    private var soundToggle: some View {
        Toggle(isOn: $themeManager.soundEnabled) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Sonidos de alerta")
                    .font(DesignSystem.body())
                    .foregroundColor(DesignSystem.primaryText)
                Text("Reproducir sonidos para notificaciones importantes")
                    .font(DesignSystem.caption())
                    .foregroundColor(DesignSystem.textGray)
            }
        }
        .tint(DesignSystem.primaryBlue)
        .onChange(of: themeManager.soundEnabled) { _, _ in
            themeManager.saveSettings()
        }
    }
    
    private var hapticToggle: some View {
        Toggle(isOn: $themeManager.hapticEnabled) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Vibración")
                    .font(DesignSystem.body())
                    .foregroundColor(DesignSystem.primaryText)
                Text("Vibración táctil para interacciones y alertas")
                    .font(DesignSystem.caption())
                    .foregroundColor(DesignSystem.textGray)
            }
        }
        .tint(DesignSystem.primaryBlue)
        .onChange(of: themeManager.hapticEnabled) { _, _ in
            themeManager.saveSettings()
        }
    }
    
    private var aboutButton: some View {
        Button(action: { showingAbout = true }) {
            HStack {
                Text("Acerca de HeatShield")
                    .font(DesignSystem.body())
                    .foregroundColor(DesignSystem.primaryText)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(DesignSystem.textGray)
            }
        }
    }
    
    private var privacyButton: some View {
        Button(action: { showingPrivacy = true }) {
            HStack {
                Text("Privacidad y datos")
                    .font(DesignSystem.body())
                    .foregroundColor(DesignSystem.primaryText)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(DesignSystem.textGray)
            }
        }
    }
    
    private var versionInfo: some View {
        HStack {
            Text("Versión")
                .font(DesignSystem.body())
                .foregroundColor(DesignSystem.primaryText)
            Spacer()
            Text("1.0.0")
                .font(DesignSystem.body())
                .foregroundColor(DesignSystem.textGray)
        }
    }
}

// MARK: - Alerts Content
struct AlertsContent: View {
    @ObservedObject var themeManager: ThemeManager
    @StateObject private var weatherManager = WeatherManager()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var notificationManager = NotificationManager()
    @State private var alertsEnabled = true
    @State private var temperatureThreshold = 35.0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Weather Status
                if let weather = weatherManager.currentWeather {
                    weatherStatusCard(weather: weather)
                }
                
                // Alert Configuration
                alertConfigurationCard
                
                Spacer(minLength: 20)
            }
        }
        .onAppear {
            setupLocationAndWeather()
        }
    }
    
    private func weatherStatusCard(weather: WeatherData) -> some View {
        CardView {
            VStack(spacing: 16) {
                HStack {
                    Text("Estado Climático Actual")
                        .font(DesignSystem.headline())
                        .foregroundColor(DesignSystem.primaryText)
                    Spacer()
                    Image(systemName: weather.icon)
                        .font(.title2)
                        .foregroundColor(DesignSystem.primaryBlue)
                }
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(weather.temperature)°C")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(DesignSystem.primaryText)
                        
                        Text("Sensación térmica: \(weather.feelsLike)°C")
                            .font(DesignSystem.caption())
                            .foregroundColor(DesignSystem.textGray)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Image(systemName: weather.heatIndex.icon)
                        Text(weather.heatIndex.rawValue)
                            .fontWeight(.semibold)
                    }
                    .font(DesignSystem.caption())
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(weather.heatIndex.color)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(.horizontal, DesignSystem.padding)
    }
    
    private var alertConfigurationCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: "gear.circle.fill")
                        .foregroundColor(DesignSystem.primaryBlue)
                    Text("Configuración de Alertas")
                        .font(DesignSystem.headline())
                        .foregroundColor(DesignSystem.primaryText)
                    Spacer()
                }
                
                VStack(spacing: 16) {
                    Toggle(isOn: $alertsEnabled) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Activar alertas de calor")
                                .font(DesignSystem.body())
                                .foregroundColor(DesignSystem.primaryText)
                            Text("Recibe notificaciones cuando sea necesario")
                                .font(DesignSystem.caption())
                                .foregroundColor(DesignSystem.textGray)
                        }
                    }
                    .tint(DesignSystem.primaryBlue)
                    
                    if alertsEnabled {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Temperatura de alerta: \(Int(temperatureThreshold))°C")
                                .font(DesignSystem.body())
                                .foregroundColor(DesignSystem.primaryText)
                            
                            Slider(value: $temperatureThreshold, in: 25...45, step: 1)
                                .tint(DesignSystem.primaryBlue)
                            
                            HStack {
                                Text("25°C")
                                    .font(DesignSystem.caption())
                                    .foregroundColor(DesignSystem.textGray)
                                Spacer()
                                Text("45°C")
                                    .font(DesignSystem.caption())
                                    .foregroundColor(DesignSystem.textGray)
                            }
                        }
                        
                        Toggle(isOn: $notificationManager.isAuthorized) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Notificaciones push")
                                    .font(DesignSystem.body())
                                    .foregroundColor(DesignSystem.primaryText)
                                Text("Permite el envío de alertas automáticas")
                                    .font(DesignSystem.caption())
                                    .foregroundColor(DesignSystem.textGray)
                            }
                        }
                        .tint(DesignSystem.primaryBlue)
                        .onChange(of: notificationManager.isAuthorized) { oldValue, newValue in
                            if newValue && !oldValue {
                                notificationManager.requestPermission()
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, DesignSystem.padding)
    }
    
    private func setupLocationAndWeather() {
        locationManager.requestPermission()
        if let location = locationManager.location {
            weatherManager.fetchWeather(for: location)
        }
    }
}

// MARK: - About Sheet
struct AboutSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackground()
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 16) {
                            Image(systemName: "shield.fill")
                                .font(.system(size: 60))
                                .foregroundColor(DesignSystem.primaryBlue)
                            
                            Text("HeatShield")
                                .font(DesignSystem.title1())
                                .foregroundColor(DesignSystem.primaryText)
                            
                            Text("Versión 1.0.0")
                                .font(DesignSystem.body())
                                .foregroundColor(DesignSystem.textGray)
                        }
                        .padding(.top, 20)
                        
                        CardView {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Nuestra Misión")
                                    .font(DesignSystem.headline())
                                    .foregroundColor(DesignSystem.primaryText)
                                
                                Text("HeatShield es una aplicación diseñada para proteger vidas durante eventos de calor extremo. Proporcionamos herramientas inteligentes para encontrar refugio, evaluar la preparación del hogar y recibir alertas críticas de seguridad.")
                                    .font(DesignSystem.body())
                                    .foregroundColor(DesignSystem.textGray)
                            }
                        }
                        .padding(.horizontal, DesignSystem.padding)
                    }
                }
            }
            .navigationTitle("Acerca de")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Privacy Sheet
struct PrivacySheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackground()
                
                ScrollView {
                    VStack(spacing: 20) {
                        CardView {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Tu Privacidad")
                                    .font(DesignSystem.headline())
                                    .foregroundColor(DesignSystem.primaryText)
                                
                                Text("HeatShield respeta tu privacidad y protege tus datos personales. Todos los datos se almacenan localmente en tu dispositivo.")
                                    .font(DesignSystem.body())
                                    .foregroundColor(DesignSystem.textGray)
                            }
                        }
                        .padding(.horizontal, DesignSystem.padding)
                    }
                }
            }
            .navigationTitle("Privacidad")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }
}
