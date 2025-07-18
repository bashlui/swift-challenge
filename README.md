# HeatShield  
**Smart Protection Against Extreme Heat**

An iOS application developed in SwiftUI that protects lives during extreme heat events by providing smart tools to find shelter, assess home preparedness, and receive critical safety alerts.

---

## Key Features

### Real-Time Climate Monitoring
- Integration with OpenWeatherMap API
- Up-to-date weather data (temperature, humidity, wind)
- Heat index with danger levels: Safe, Caution, Warning, Danger, Extreme
- Celsius and Fahrenheit support

### Cool Zones Map
- GPS localization of nearby shelters
- Zone types: libraries, shopping malls, hospitals, parks, community centers
- Real-time distance calculation
- Integrated navigation with Apple Maps
- Schedule indicators (24/7 vs. limited hours)

### Home Thermal Assessment
- Interactive 8-question questionnaire
- Smart scoring system (0-16 points)
- Personalized improvement recommendations
- Energy savings estimations
- Thermal efficiency analysis

### Personalized Alert System
- Temperature threshold configuration
- Automatic push notifications
- Real-time heat danger statuses
- iOS notification system integration

### Data Management
- Full integration with SwiftData
- Local storage of records
- Intuitive interface for CRUD operations
- System statistics

### Advanced Settings
- Adaptive themes (light/dark/system)
- Configurable temperature units
- Granular notification control
- Sound and vibration settings

---

## Project Architecture

### File Structure
```
HeatShield/
├── App.swift              # Entry point + SwiftData container
├── Models.swift           # Data models & enums
├── Managers.swift         # Business logic managers
├── DesignSystem.swift     # UI components & design tokens
├── ContentView.swift      # TabView + Home + SwiftData integration
├── MapView.swift          # Interactive map with cool zones
├── AssessmentView.swift   # Home thermal assessment
└── SettingsAlertsView.swift # Settings & alerts management
```

### Architecture Pattern
- MVVM (Model-View-ViewModel) with \`@ObservableObject\`
- Specialized Managers for business logic
- Reusable components with \`@ViewBuilder\`
- Clear separation of responsibilities

---

## Technologies Used

### iOS Frameworks
- SwiftUI - Declarative user interface
- SwiftData - Data persistence
- CoreLocation - Location services
- MapKit - Interactive maps
- UserNotifications - Push notifications

### External APIs
- OpenWeatherMap API - Real-time weather data
- Apple Maps - Navigation and directions

---

## UI/UX
- Custom design system with consistent tokens
- Smooth gradients and animations
- SF Symbols for iconography
- Dark Mode support
- Responsive design for various screen sizes

---

## Installation and Configuration

### Requirements
- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+
- Apple Developer Account

### Project Setup

**Clone the repository:**
```bash
git clone https://github.com/tu-usuario/heatshield.git
cd heatshield
```

**Configure OpenWeatherMap API Key:**
- Register at OpenWeatherMap
- Create a \`Config.plist\` file:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>WeatherAPIKey</key>
    <string>YOUR_API_KEY_HERE</string>
</dict>
</plist>
```

**Configure permissions in \`Info.plist\`:**
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show you nearby cool zones</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need your location for emergency heat alerts</string>
```

**Compile and run:**
```bash
# Open in Xcode
open HeatShield.xcodeproj

# Or use xcodebuild
xcodebuild -project HeatShield.xcodeproj -scheme HeatShield -destination 'platform=iOS Simulator,name=iPhone 15'
```

---

## Detailed Functionalities

### Heat Index System

| Temperature     | Index     | Color   | Recommendation              |
|----------------|-----------|---------|-----------------------------|
| < 27°C          | Safe      | Green   | Normal activity             |
| 27-32°C         | Caution   | Yellow  | Frequent hydration          |
| 32-37°C         | Warning   | Orange  | Limit outdoor activity      |
| 37-42°C         | Danger    | Red     | Seek immediate shelter      |
| > 42°C          | Extreme   | Purple  | Medical emergency           |

---

### Home Assessment System

**Categories evaluated:**
- Roof reflectivity
- Cross-ventilation
- Thermal curtains
- Outdoor shading
- Thermal insulation
- Climate control systems
- Specialized glazing
- Opening management

**Scoring:**
- 14–16 points: Excellent (Optimally prepared home)
- 10–13 points: Very Good (Solid preparedness)
- 6–9 points: Good (Recommended improvements)
- 3–5 points: Needs improvements (Significant adaptations)
- 0–2 points: Critical (Urgent intervention)

---

### Cool Zone Types

- **Libraries** - Free air conditioning, public spaces  
- **Shopping Malls** - Multiple air-conditioned areas  
- **Hospitals** - 24/7 availability, medical attention  
- **Parks** - Natural shaded areas, water fountains  
- **Community Centers** - Official authorized shelters  

---

## Development and Contribution

### Development Structure

**Manager Example:**
```swift
class WeatherManager: ObservableObject {
    @Published var currentWeather: WeatherData?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchWeather(for location: CLLocation) {
        // Implementation...
    }
}
```

**Component View Example:**
```swift
struct WeatherCard: View {
    @ObservedObject var weatherManager: WeatherManager

    var body: some View {
        CardView {
            // UI implementation...
        }
    }
}
```

---

## Testing

```bash
# Run unit tests
xcodebuild test -project HeatShield.xcodeproj -scheme HeatShield -destination 'platform=iOS Simulator,name=iPhone 15'

# UI tests
xcodebuild test -project HeatShield.xcodeproj -scheme HeatShield -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:HeatShieldUITests
```

---

## Code Conventions

- **Naming:** PascalCase for types, camelCase for variables
- **Organization:** Groups by functionality with \`// MARK:\`
- **Documentation:** Swift comments for public APIs
- **SwiftLint:** Configuration included for consistency

---

## Roadmap and Future Features

### Version 1.1
- iOS Widget for current temperature
- Location-based scheduled notifications
- Offline mode with cached data
- Full localization (Spanish/English)

### Version 1.2
- Apple Watch companion app
- HealthKit integration
- Predictive heat analysis
- Share home assessments

### Version 2.0
- ARKit for temperature visualization
- Integration with IoT home devices
- Community and collaborative reporting
- Machine Learning for personalized recommendations

---

## Security and Privacy

### Privacy Principles
- **Local data:** All personal information is stored on the device
- **Minimum location:** Only requested when necessary
- **No tracking:** No behavioral data is collected
- **Full transparency:** Clear and accessible privacy policy

---

## License

This project is licensed under the MIT License - see the file `LICENSE` for details.

---

## Contributors

- Luis Antonio Bolaina Dominguez  
- Victor Abel Camacho Rodriguez  
- Óscar Cardenas Valdez  
- Hermann Pauwells Rivera

---

## Acknowledgments

- OpenWeatherMap for providing reliable weather data  
- Apple for the iOS development tools  
- SwiftUI Community for resources and inspiration  
- Public health organizations for research on extreme heat events

---

**Important:** HeatShield is an assistance tool and does not replace professional medical judgment. In case of a medical emergency, immediately contact local emergency services.

**Developed with love to protect lives during extreme heat events.**
