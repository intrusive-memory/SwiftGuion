//
//  Item.swift
//  GuionDocumentApp
//
//  Created by TOM STOVALL on 10/11/25.
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
