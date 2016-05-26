//
//  Weather+CoreDataProperties.swift
//  Memories
//
//  Created by admin on 26.05.16.
//  Copyright © 2016 gluglu. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Weather {

    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var descriptionText: String?
    @NSManaged var temperature: NSNumber?
    @NSManaged var openweatherIconId: NSNumber?
    @NSManaged var country: String?
    @NSManaged var locationName: String?
    @NSManaged var moment: Moment?

}
