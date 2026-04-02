//
//  Item.swift
//  LearnNow
//
//  Created by fanxi on 3/31/26.
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
