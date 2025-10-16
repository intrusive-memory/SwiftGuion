//
//  Item.swift
//  GuionViewer for iPad
//
//  Created by TOM STOVALL on 10/15/25.
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
