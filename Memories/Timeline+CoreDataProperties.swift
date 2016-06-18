import Foundation
import CoreData

extension Timeline {

    @NSManaged var creationDate: NSDate?
    @NSManaged var name: String?
    @NSManaged var descriptiontext: String?
    @NSManaged var moments: Set<Moment>?

}
