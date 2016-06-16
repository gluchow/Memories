import UIKit
import MapKit
import CoreLocation
import MobileCoreServices
import Contacts
import ContactsUI

class NewMomentViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate,
        UIImagePickerControllerDelegate, UINavigationControllerDelegate, CNContactPickerDelegate {
    
    @IBOutlet weak var nameTextField: UITextField! { didSet { nameTextField.delegate = self } }
    @IBOutlet weak var descriptionTextField: UITextView!

    var timeline: Timeline?
    var moment: Moment? // TODO beim Einstieg für Neuanlage auf nil setzen
    var pickedImageUrl: String?
    var pickedContacts = [String]()
    
    private var locationManager: CLLocationManager!
    
    private var momentDao = MomentDao()
    private var locationDao = LocationDAO()
    
    // TODO nur zu Testzwecken - Umbauen der gesamten View in eine statische Tabelle
    @IBOutlet weak var testImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.becomeFirstResponder()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(save(_:)))
        
        initLocationManager()
    }

    func save(sender: AnyObject) {
        do {
            // TODO Unterscheidung beim Editieren eines Moments -> nil?
            moment = try self.momentDao.createNewMomentEntity(forName: self.nameTextField.text!, withinTimeline: self.timeline!)
            moment?.descriptiontext = self.descriptionTextField.text
            
            if let currentLocation = self.locationManager.location {
                persistMomentWithWeatherAndCloseViewOnSuccess(currentLocation: currentLocation)
                
            } else {
                persistMomentAndCloseViewOnSuccess()
            }
            
        } catch MomentError.NameValidationError {
            showErrorMessage("Name must have at least 3 characters.")
        } catch {
            showErrorMessage("Could not create a new moment. Unexpected error occurred.")
        }
           
    }

    private func persistMomentWithWeatherAndCloseViewOnSuccess(currentLocation location: CLLocation) {
        print("current location: \(location)")
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        WeatherService.sharedInstance.fetchWeather(forLatitude: latitude, andLongitude: longitude) {
            callback in
            
            if let error = callback.error {
                print("Weather data could't be fetched. Error code: \(error.code)")
            }
            
            self.moment?.weather = callback.weather
            callback.weather?.moment = self.moment
            
            self.fetchLocationDataAndPersist(forLatitude: latitude, andLongitude: longitude)

        }
    }
    
    private func fetchLocationDataAndPersist(forLatitude latitude: Double, andLongitude longitude: Double) {
        if moment == nil {
            return
        }
        
        moment?.location = self.locationDao.createNewLocationEntity(withLatitude: latitude, andLongitude: longitude)
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        print(location)
        
        CLGeocoder().reverseGeocodeLocation(location) {
            (placemarks, error) -> Void in
            print(location)
            
            if error != nil {
                print("Error in reverse geocoder: " + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0]
                print("Reverse geocoder - Placemark gefunden: ")
                print(pm.country)
                print(pm.locality)
            }
            else {
                print("No Data from reverse geocoder received.")
            }
        }
        
        self.persistMomentAndCloseViewOnSuccess()
    }
    
    private func persistMomentAndCloseViewOnSuccess() {
        if moment == nil {
            return
        }
        
        moment!.contacts = pickedContacts
        moment!.imageUrl = pickedImageUrl
        
        let persistResult = self.momentDao.persistMoment(self.moment!)
        
        if let error = persistResult.error {
            self.showErrorMessage("Moment couldn't be saved. \(error.domain). Error code: \(error.code)") // TODO was soll dem Benutzer gezeigt werden?
            return
        }
        
        // success, just close pop the top (current) view controller
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func showContactsAction() {
        let contactPickerViewController = CNContactPickerViewController()
        contactPickerViewController.delegate = self
        presentViewController(contactPickerViewController, animated: true, completion: nil)
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

    
    // ------------------------------------------------------------------------------------------------------
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == nameTextField {
            textField.resignFirstResponder()
            // TODO auslesen..
        }
        // TODO Beschreibungsfeld auslesen?
        
        return true
    }
    
    
    // ------------------------------------------------------------------------------------------------------
    // MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate
  
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        self.testImage.image = image
        self.testImage.contentMode = .ScaleAspectFit
        
        let imageUrl = info[UIImagePickerControllerReferenceURL] as? NSURL
        print("image url: \(imageUrl?.absoluteString)")
        pickedImageUrl = imageUrl?.absoluteString
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // ------------------------------------------------------------------------------------------------------
    // MARK: CNContactPickerDelegate
    
    func contactPicker(picker: CNContactPickerViewController, didSelectContact contact: CNContact) {
        pickedContacts.append("\(contact.givenName) \(contact.familyName)")
        
        // modale View schließen
        dismissViewControllerAnimated(true, completion: nil)
    }
}
