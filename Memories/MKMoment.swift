import MapKit

extension Moment: MKAnnotation {
    
    func hasCoordinates() -> Bool {
        return (location != nil) && (location?.latitude != nil) && (location?.longitude != nil)
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: location!.latitude!.doubleValue, longitude: location!.longitude!.doubleValue)
    }
    
    var title: String? {
        return name
    }
    
    var subtitle: String? {
        return Utils.dateString(creationDate)
    }
}