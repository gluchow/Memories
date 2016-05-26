import Foundation
import CoreData

class WeatherDao: BaseDao {

    func createNewWeatherEntity() -> Weather {
        return createEntity(forName: Weather.EntityName) as! Weather
    }

}