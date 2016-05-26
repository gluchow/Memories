import UIKit
import MapKit
import CoreLocation

class NewMomentViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var nameTextField: UITextField! { didSet { nameTextField.delegate = self } }
    @IBOutlet weak var descriptionTextField: UITextView!

    
    // TODO so okay? anfangs noch nicht gesetzt. für save() 
    var timeline: Timeline?
    
    private var locationManager: CLLocationManager!

    private var momentDao = MomentDao()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.becomeFirstResponder()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(save(_:)))
        
        initLocationManager()
    }
    
    func save(sender: AnyObject) {
        let momentEntity = self.momentDao.createNewMomentEntity(forName: self.nameTextField.text!, withinTimeline: self.timeline!)
        momentEntity.descriptiontext = self.descriptionTextField.text

        if let currentLocation = self.locationManager.location {
            persistMomentWithWeatherAndCloseViewOnSuccess(forMoment: momentEntity, andCurrentLocation: currentLocation)
            return
            
        } else {
            persistMomentAndCloseViewOnSuccess(momentEntity)
        }
   
    }
    
    private func persistMomentWithWeatherAndCloseViewOnSuccess(forMoment moment: Moment, andCurrentLocation location: CLLocation) {
        print("current location: \(location)")
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        
        
        moment.latitude = latitude
        moment.longitude = longitude
        
        WeatherService.sharedInstance.fetchWeather(forLatitude: latitude, andLongitude: longitude) {
            callback in
            
            if let error = callback.error {
                print("Wetterdaten konnten nicht abgefragt werden. Fehler-Code: \(error.code)")
            }
            
            moment.weather = callback.weather
            callback.weather?.moment = moment // TODO benötigt, oder kümmert sich core data drum?

            self.persistMomentAndCloseViewOnSuccess(moment)
        }
    }

    private func persistMomentAndCloseViewOnSuccess(momentEntity: Moment) {
        let persistResult = self.momentDao.persistMoment(momentEntity)
        
        if let error = persistResult.error {
            self.showErrorMessage("Moment konnte nicht gespeichert werden. Fehler-Code: \(error.code)") // TODO was soll dem Benutzer gezeigt werden?
            return
        }
        
        // success, just close pop the top (current) view controller
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == nameTextField {
            textField.resignFirstResponder()
            // TODO auslesen..
        }
        // TODO Beschreibungsfeld auslesen?
       
        return true
    }
    
    private func initLocationManager() {
        if (CLLocationManager.locationServicesEnabled()) {
            print("Location service is enabled")
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation() // TODO benötigt oder ist currentLocation auch so bekannt?
        }
    }
    
}
