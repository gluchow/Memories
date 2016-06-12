import Foundation
import CoreData

extension Moment {

    @NSManaged var creationDate: NSDate?
    @NSManaged var descriptiontext: String?
    @NSManaged var name: String?
    @NSManaged var timeline: Timeline?
    @NSManaged var weather: Weather?
    @NSManaged var location: Location?

}
