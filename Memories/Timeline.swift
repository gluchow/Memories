//
//  Timeline.swift
//  Memories
//
//  Created by admin on 16.05.16.
//  Copyright © 2016 gluglu. All rights reserved.
//

import Foundation
import CoreData

class Timeline: NSManagedObject {
    static let EntityName = "Timeline"
    
    var momentsArray: [Moment] {
        get {
            return moments == nil ? [Moment]() : Array(moments!)
        }
    }
}
