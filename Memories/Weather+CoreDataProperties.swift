import Foundation
import CoreData

extension Weather {

    @NSManaged var country: String?
    @NSManaged var descriptionText: String?
    @NSManaged var latitude: NSNumber?
    @NSManaged var locationName: String?
    @NSManaged var longitude: NSNumber?
    @NSManaged var openweatherIconId: NSNumber?
    @NSManaged var temperature: NSNumber?
    @NSManaged var moment: Moment?

}
