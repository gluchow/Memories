import Alamofire
import SwiftyJSON

class WeatherService: NSObject {
    
    typealias WeatherResponseCallback = (weather: Weather?, error: NSError?) -> Void
    
    let CurrentWeatherBaseUrl = "http://api.openweathermap.org/data/2.5/weather"
    let APIKey = "0d7a30389dcee9d56882e9579d1d171b"
    let ResponseFormat = "json"
    let TemperatureUnit = "metric" // = Celsius
    
    let manager = Alamofire.Manager.sharedInstance
    
    override init() {
        super.init()
    }
    
    internal class var sharedInstance: WeatherService {
        struct Singleton {
            static let instance = WeatherService()
        }
        return Singleton.instance
    }
    
    func fetchWeather(forLatitude lat: Double, andLongitude lon: Double, withResponseCallback callback: WeatherResponseCallback) {
        let parameter = [ParameterName.ApiKey: APIKey,
                         ParameterName.ResponseFormatMode: ResponseFormat,
                         ParameterName.Units: TemperatureUnit,
                         ParameterName.Latitude: "\(lat)",
                         ParameterName.Longitude:"\(lon)"]
        
        let urlString = urlWithParameter(parameter)
        
        if let url = NSURL(string: urlString) {
            print("Try to request weather data - url: \(urlString)")
            executeWeatherRequest(forUrl: url, withResponseCallback: callback)
        }
    }
    
    private func executeWeatherRequest(forUrl url: NSURL, withResponseCallback callback: WeatherResponseCallback) {
        manager
            .request(NSURLRequest(URL: url))
            .responseJSON(options: NSJSONReadingOptions.AllowFragments) {
                (response) -> Void in

                print("Request weather data - response status code: \(response.response?.statusCode)")
                
                // Prüfe ob Wetterdaten auswertbar sind:
                if response.result.error != nil {
                    callback(weather: nil, error: response.result.error)
                    return
                }
                if response.response?.statusCode != 200 {
                    callback(weather: nil, error: NSError(domain: "HTTP response code is not 200. Something went wrong.", code: response.response!.statusCode, userInfo: nil))
                    return
                }
                
                let result = response.result.value as! Dictionary<String, AnyObject>
                // Response doesn't have weather data
                if result["weather"] == nil {
                    callback(weather: nil, error: NSError(domain: "No weather data containing in response.", code: response.response!.statusCode, userInfo: nil))
                    return
                }
                
                // Weather data is available. Create a new CoreData enitity and return it.
                self.createWeather(result, withResponseCallback: callback)

        }
    }
    
    private func createWeather(result: Dictionary<String, AnyObject>, withResponseCallback callback: WeatherResponseCallback) {
        let weatherDao = WeatherDao()
        let weatherEntity = weatherDao.createNewWeatherEntity()
        
        if let weatherJson = result["weather"] {
            weatherEntity.descriptionText = JSON(weatherJson)[0]["description"].stringValue
        }
        if let mainJson = result["main"] {
            weatherEntity.temperature = JSON(mainJson)["temp"].floatValue
        }
        if let coordinatesJson = result["coord"] {
            weatherEntity.latitude = JSON(coordinatesJson)["lat"].doubleValue
            weatherEntity.longitude = JSON(coordinatesJson)["lon"].doubleValue
        }
        if let sysJson = result["sys"] {
            weatherEntity.country = JSON(sysJson)["country"].stringValue
        }
        if let locationName = result["name"] {
            weatherEntity.locationName = JSON(locationName).stringValue
        }

        callback(weather: weatherEntity, error: nil)
    }
    
    private func urlWithParameter(parameter: Dictionary<String, String>) -> String {
        var urlString = "\(CurrentWeatherBaseUrl)?"
        for (parameterName, parameterValue) in parameter {
            urlString = urlString + parameterName + "=" + parameterValue + "&"
        }
        return urlString
    }

    struct ParameterName {
        static let ApiKey = "APPID"
        static let ResponseFormatMode = "mode"
        static let Latitude = "lat"
        static let Longitude = "lon"
        static let Units = "units"
    }
    
}
