import Foundation
import CoreData
import UIKit

class BaseDao {
    struct ErrorCode {
        static let ConstraintConflict = 133021
    }
    
    static let EndUserMessageKey = "end user message"
   
    var managedContext: NSManagedObjectContext {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }
    
    func createEntity(forName name: String) -> NSManagedObject {
        let entity = NSEntityDescription.entityForName(name, inManagedObjectContext:managedContext)
        return NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
    }


}