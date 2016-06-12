import Foundation
import CoreData

extension Location {

    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var country: String?
    @NSManaged var city: String?
    @NSManaged var moment: Moment?

}
