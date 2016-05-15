//
//  Moment.swift
//  Memories
//
//  Created by admin on 15.05.16.
//  Copyright © 2016 gluglu. All rights reserved.
//

import Foundation

class Moment {
    var name: String
    var beschreibung: String?
    // TODO: Teilnehmer
    // TODO: Foto
    // TODO: Wetterdaten
    var location: Location?
    
    
    init(name: String) {
        self.name = name
    }
    
    struct Location {
        let latitude: Double
        let longitude: Double
    }
}