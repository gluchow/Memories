import Alamofire
import SwiftyJSON

class WeatherService: NSObject {
    
    typealias WeatherResponseCallback = (weather: Weather?, error: NSError?)
    
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
    
    func fetchWeather(forLatitude lat: Double, andLongitude lon: Double, callback: WeatherResponseCallback) {
        let parameter = [ParameterName.ApiKey: APIKey,
                         ParameterName.ResponseFormatMode: ResponseFormat,
                         ParameterName.Units: TemperatureUnit,
                         ParameterName.Latitude: "\(lat)",
                         ParameterName.Longitude:"\(lon)"]
        
        let urlString = urlWithParameter(parameter)
        
        if let url = NSURL(string: urlString) {
            manager
                .request(NSURLRequest(URL: url))
                .responseJSON(options: NSJSONReadingOptions.AllowFragments) {
                    (response) -> Void in
                    
                    print("response: \(response)")
                    // TODO Konvertieren in Weather-Objekt und der Callback-Methode übergeben
            }
        }
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
