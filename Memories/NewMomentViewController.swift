import UIKit
import MapKit
import CoreLocation
import MobileCoreServices

class NewMomentViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
    
    @IBAction func takePhotoAction() {
        print("take photo...")
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) { // TODO wieder zurück auf .Camera (nicht im Simulator möglich)
            let picker = UIImagePickerController()
            picker.sourceType = .PhotoLibrary // TODO wieder zurück auf .Camera (nicht im Simulator möglich)
            picker.mediaTypes = [kUTTypeImage as String] // TODO prüfen, ob das so i.O. ist
            picker.delegate = self
            picker.allowsEditing = true
            presentViewController(picker, animated: true, completion: nil)
        }
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        // TODO mit dem Image etwas machen (in Entität speichern, anzeigen, ...?)
        print("image picked: \(image.debugDescription)")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
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

        // TODO nur zum Testen, später entfernen oder übernehmen, Async lib?
        checkReverseGeocode(forLatitude: latitude, andLongitude: longitude)
        
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
    
    private func checkReverseGeocode(forLatitude latitude: Double, andLongitude longitude: Double) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        print(location)
        
        CLGeocoder().reverseGeocodeLocation(location) {
            (placemarks, error) -> Void in
            print(location)
            
            if error != nil {
                print("Reverse geocoder fehlgeschlagen: " + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0]
                print("Reverse geocoder - Placemark gefunden: ")
                print(pm.country)
                print(pm.locality)
            }
            else {
                print("Keine Daten vom Reverse geocoder bekommen.")
            }
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
