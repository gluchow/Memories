//
//  Moment+CoreDataProperties.swift
//  Memories
//
//  Created by admin on 16.05.16.
//  Copyright © 2016 gluglu. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Moment {

    @NSManaged var creationDate: NSDate?
    @NSManaged var descriptiontext: String?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var name: String?
    @NSManaged var timeline: Timeline?

}
