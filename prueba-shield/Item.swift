//
//  Item.swift
//  prueba-shield
//
//  Created by Alumno on 08/06/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
