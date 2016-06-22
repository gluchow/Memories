import Foundation
import CoreData


class Moment: NSManagedObject {
    static let EntityName = "Moment"
    
    var locationString: String {
        get {
            var result = ""
            if let city = location?.city {
                result.appendContentsOf(city)
            }
            
            if let country = location?.country {
                if !result.characters.isEmpty {
                    result.appendContentsOf(", ")
                }
                result.appendContentsOf(country)
            }

            return result
        }
    }
}
