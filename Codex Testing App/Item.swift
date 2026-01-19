//
//  Item.swift
//  Codex Testing App
//
//  Created by chase morgan on 1/19/26.
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
