//
//  Timeline.swift
//  Memories
//
//  Created by admin on 15.05.16.
//  Copyright © 2016 gluglu. All rights reserved.
//

import Foundation

class Timeline {
    var name: String
    var creationDate: NSDate
    var moments: [Moment]?
    
    init(name: String) {
        self.name = name
        self.creationDate = NSDate()
    }
    
}