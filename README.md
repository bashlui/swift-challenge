# 🛡️ HeatShield

**Protección Inteligente contra el Calor Extremo**

Una aplicación iOS desarrollada en SwiftUI que protege vidas durante eventos de calor extremo, proporcionando herramientas inteligentes para encontrar refugio, evaluar la preparación del hogar y recibir alertas críticas de seguridad.

## 📱 Características Principales

### 🌡️ **Monitoreo Climático en Tiempo Real**
- Integración con OpenWeatherMap API
- Datos meteorológicos actualizados (temperatura, humedad, viento)
- Índice de calor con niveles de peligro (Seguro, Precaución, Advertencia, Peligro, Extremo)
- Soporte para Celsius y Fahrenheit

### 🗺️ **Mapa de Zonas Frescas**
- Localización GPS de refugios cercanos
- Tipos de zonas: bibliotecas, centros comerciales, hospitales, parques, centros comunitarios
- Cálculo de distancias en tiempo real
- Navegación integrada con Apple Maps
- Indicadores de horarios (24/7 vs horarios limitados)

### 🏠 **Evaluación Térmica del Hogar**
- Cuestionario interactivo de 8 preguntas
- Sistema de puntuación inteligente (0-16 puntos)
- Recomendaciones personalizadas de mejora
- Estimaciones de ahorro energético
- Análisis de eficiencia térmica

### ⚠️ **Sistema de Alertas Personalizado**
- Configuración de umbrales de temperatura
- Notificaciones push automáticas
- Estados de peligro por calor en tiempo real
- Integración con el sistema de notificaciones de iOS

### 📋 **Gestión de Datos**
- Integración completa con SwiftData
- Almacenamiento local de registros
- Interfaz intuitiva para CRUD operations
- Estadísticas del sistema

### ⚙️ **Configuración Avanzada**
- Temas adaptativos (claro/oscuro/sistema)
- Unidades de temperatura configurables
- Control granular de notificaciones
- Configuración de sonidos y vibración

## 🏗️ Arquitectura del Proyecto

### 📁 **Estructura de Archivos**
```
📁 HeatShield/
├── 📱 App.swift                    # Entry point + SwiftData container
├── 🧩 Models.swift                 # Data models & enums
├── 🧰 Managers.swift               # Business logic managers
├── 🎨 DesignSystem.swift           # UI components & design tokens
├── 🏠 ContentView.swift            # TabView + Home + SwiftData integration
├── 🗺️ MapView.swift               # Interactive map with cool zones
├── 🏠 AssessmentView.swift         # Home thermal assessment
└── ⚙️ SettingsAlertsView.swift     # Settings & alerts management
```

### 🏛️ **Patrón de Arquitectura**
- **MVVM (Model-View-ViewModel)** con `@ObservableObject`
- **Managers especializados** para lógica de negocio
- **Componentes reutilizables** con `@ViewBuilder`
- **Separación clara de responsabilidades**

## 🛠️ Tecnologías Utilizadas

### 📱 **Frameworks iOS**
- **SwiftUI** - Interface de usuario declarativa
- **SwiftData** - Persistencia de datos
- **CoreLocation** - Servicios de ubicación
- **MapKit** - Mapas interactivos
- **UserNotifications** - Notificaciones push

### 🌐 **APIs Externas**
- **OpenWeatherMap API** - Datos meteorológicos en tiempo real
- **Apple Maps** - Navegación y direcciones

### 🎨 **UI/UX**
- **Sistema de diseño personalizado** con tokens consistentes
- **Gradientes y animaciones** fluidas
- **SF Symbols** para iconografía
- **Soporte para Dark Mode**
- **Diseño responsive** para diferentes tamaños de pantalla

## 🚀 Instalación y Configuración

### 📋 **Requisitos**
- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+
- Cuenta de desarrollador de Apple

### ⚙️ **Configuración del Proyecto**

1. **Clonar el repositorio:**
```bash
git clone https://github.com/tu-usuario/heatshield.git
cd heatshield
```

2. **Configurar API Key de OpenWeatherMap:**
   - Registrarse en [OpenWeatherMap](https://openweathermap.org/api)
   - Crear un archivo `Config.plist`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>WeatherAPIKey</key>
    <string>TU_API_KEY_AQUI</string>
</dict>
</plist>
```

3. **Configurar permisos en Info.plist:**
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Necesitamos tu ubicación para mostrarte las zonas frescas cercanas</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Necesitamos tu ubicación para alertas de emergencia por calor</string>
```

4. **Compilar y ejecutar:**
```bash
# Abrir en Xcode
open HeatShield.xcodeproj

# O usar xcodebuild
xcodebuild -project HeatShield.xcodeproj -scheme HeatShield -destination 'platform=iOS Simulator,name=iPhone 15'
```

## 📊 Funcionalidades Detalladas

### 🌡️ **Sistema de Índice de Calor**
| Temperatura | Índice | Color | Recomendación |
|-------------|--------|-------|---------------|
| < 27°C | Seguro | 🟢 Verde | Actividad normal |
| 27-32°C | Precaución | 🟡 Amarillo | Hidratación frecuente |
| 32-37°C | Advertencia | 🟠 Naranja | Limitar actividad exterior |
| 37-42°C | Peligro | 🔴 Rojo | Buscar refugio inmediato |
| > 42°C | Extremo | 🟣 Morado | Emergencia médica |

### 🏠 **Sistema de Evaluación del Hogar**
**Categorías evaluadas:**
- Reflectividad del techo
- Ventilación cruzada
- Cortinas térmicas
- Sombra exterior
- Aislamiento térmico
- Sistemas de climatización
- Vidrios especializados
- Gestión de aberturas

**Puntuación:**
- **14-16 puntos:** 🏆 Excelente (Hogar óptimamente preparado)
- **10-13 puntos:** ⭐ Muy Bueno (Preparación sólida)
- **6-9 puntos:** 👍 Bueno (Mejoras recomendadas)
- **3-5 puntos:** ⚠️ Necesita mejoras (Adaptaciones importantes)
- **0-2 puntos:** 🚨 Crítico (Intervención urgente)

### 🗺️ **Tipos de Zonas Frescas**
- 📚 **Bibliotecas** - Aire acondicionado gratuito, espacios públicos
- 🏢 **Centros Comerciales** - Múltiples áreas climatizadas
- 🏥 **Hospitales** - Disponibilidad 24/7, atención médica
- 🌳 **Parques** - Áreas sombreadas naturales, fuentes de agua
- 👥 **Centros Comunitarios** - Refugios oficiales autorizados

## 🔧 Desarrollo y Contribución

### 🏗️ **Estructura de Desarrollo**

```swift
// Ejemplo de Manager
class WeatherManager: ObservableObject {
    @Published var currentWeather: WeatherData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchWeather(for location: CLLocation) {
        // Implementación...
    }
}

// Ejemplo de Vista Componente
struct WeatherCard: View {
    @ObservedObject var weatherManager: WeatherManager
    
    var body: some View {
        CardView {
            // UI implementation...
        }
    }
}
```

### 🧪 **Testing**
```bash
# Ejecutar tests unitarios
xcodebuild test -project HeatShield.xcodeproj -scheme HeatShield -destination 'platform=iOS Simulator,name=iPhone 15'

# Tests de UI
xcodebuild test -project HeatShield.xcodeproj -scheme HeatShield -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:HeatShieldUITests
```

### 📝 **Convenciones de Código**
- **Nomenclatura:** PascalCase para tipos, camelCase para variables
- **Organización:** Grupos por funcionalidad con `// MARK:`
- **Documentación:** Comentarios Swift para APIs públicas
- **SwiftLint:** Configuración incluida para consistencia

## 🔮 Roadmap y Funcionalidades Futuras

### 📅 **Versión 1.1**
- [ ] Widget iOS para temperatura actual
- [ ] Notificaciones programadas por ubicación
- [ ] Modo offline con datos en caché
- [ ] Localización completa (español/inglés)

### 📅 **Versión 1.2**
- [ ] Apple Watch companion app
- [ ] Integración con HealthKit
- [ ] Análisis predictivo de calor
- [ ] Compartir evaluaciones del hogar

### 📅 **Versión 2.0**
- [ ] ARKit para visualización de temperatura
- [ ] Integración con IoT home devices
- [ ] Comunidad y reportes colaborativos
- [ ] Machine Learning para recomendaciones personalizadas

## 🛡️ Seguridad y Privacidad

### 🔒 **Principios de Privacidad**
- **Datos locales:** Toda la información personal se almacena en el dispositivo
- **Ubicación mínima:** Solo se solicita cuando es necesario
- **Sin tracking:** No se recopilan datos de comportamiento
- **Transparencia total:** Política de privacidad clara y accesible


## 📄 Licencia

Este proyecto está licenciado bajo la **MIT License** - ver el archivo [LICENSE](LICENSE) para detalles.

## 👥 Contribuidores

- **Luis Antonio Bolaina Dominguez**
- **Victor Abel Camacho Rodriguez**
- **Óscar Cardenas Valdez**
- **Hermann Pauwells Rivera**

## 🙏 Agradecimientos

- **OpenWeatherMap** por proporcionar datos meteorológicos confiables
- **Apple** por las herramientas de desarrollo iOS
- **Comunidad SwiftUI** por recursos y inspiración
- **Organizaciones de salud pública** por investigación sobre eventos de calor extremo

---

**⚠️ Importante:** HeatShield es una herramienta de asistencia y no reemplaza el juicio médico profesional. En caso de emergencia médica, contacta inmediatamente a los servicios de emergencia locales.

---

*Desarrollado con ❤️ para proteger vidas durante eventos de calor extremo*
