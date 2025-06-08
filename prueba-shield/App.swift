//
//  App.swift
//  prueba-shield
//
//  Created by Alumno on 08/06/25.
//

import SwiftUI
import FirebaseCore

// En tu AppDelegate:
func application(_ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure() // ¡Esta línea es clave!
    return true
}
@main
struct HeatShieldApp: App {
    init() {
        FirebaseApp.configure() // Configura Firebase al iniciar la app
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
