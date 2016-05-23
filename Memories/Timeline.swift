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
