import Foundation
import CoreData

class LocationDAO: BaseDao {
    
    func createNewEmptyWeatherEntity() -> Location {
        return createEntity(forName: Location.EntityName) as! Location
    }
    
    func createNewLocationEntity(withLatitude lat: Double, andLongitude long: Double) -> Location {
        let contact = createNewEmptyWeatherEntity()
        contact.latitude = lat
        contact.longitude = long
        return contact
    }
    
}