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
    
    func fetchWeather(forLatitude lat: Double, andLongitude lon: Double, callback: WeatherResponseCallback) {
        let parameter = [ParameterName.ApiKey: APIKey,
                         ParameterName.ResponseFormatMode: ResponseFormat,
                         ParameterName.Units: TemperatureUnit,
                         ParameterName.Latitude: "\(lat)",
                         ParameterName.Longitude:"\(lon)"]
        
        let urlString = urlWithParameter(parameter)
        
        if let url = NSURL(string: urlString) {
            print("Request weather data - url: \(urlString)")
            handleWeatherRequest(forUrl: url, withResponseCallback: callback)
        }
    }
    
    private func handleWeatherRequest(forUrl url: NSURL, withResponseCallback callback: WeatherResponseCallback) {
        manager
            .request(NSURLRequest(URL: url))
            .responseJSON(options: NSJSONReadingOptions.AllowFragments) {
                (response) -> Void in

                print("Request weather data - response status code: \(response.response?.statusCode)")
                
                // Prüfe ob Wetterdaten auswertbar sind:
                
                if response.result.error != nil {
                    callback(weather: nil, error: NSError(domain: "Fehler beim Aufruf der Wetterdaten.", code: response.response!.statusCode, userInfo: nil))
                    return
                }
                if response.response?.statusCode != 200 {
                    callback(weather: nil, error: NSError(domain: "Fehler beim Aufruf der Wetterdaten.", code: response.response!.statusCode, userInfo: nil))
                    return
                }
                
                let result = response.result.value as! Dictionary<String, AnyObject>
                // Wetterdaten nicht im Response enthalten:
                if result["weather"] == nil {
                    callback(weather: nil, error: NSError(domain: "Keine Wetterdaten in der Antwort enthalten", code: response.response!.statusCode, userInfo: nil))
                    return
                }
                
                
                // Wetterdaten sind vorhanden, erstelle eine CoreData Entität und gib diese zurück
                self.createWeather(result, withResponseCallback: callback)

        }
    }
    
    private func createWeather(result: Dictionary<String, AnyObject>, withResponseCallback callback: WeatherResponseCallback) {
        // Ohne Konstanten aus meiner Sicht einfacher und direkt nachvollziehbar.
        if let weather = result["weather"] {
            print(JSON(weather)[0]["description"])
            print(JSON(weather)[0]["icon"])
        }
        if let main = result["main"] {
            print(JSON(main)["temp"])
        }
        if let coordinates = result["coord"] {
            print(JSON(coordinates)["lat"])
            print(JSON(coordinates)["lon"])
        }
        
        // TODO Konvertieren in Weather-Objekt (Core Data Enitität) und der Callback-Methode übergeben
        callback(weather: nil, error: nil)
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
