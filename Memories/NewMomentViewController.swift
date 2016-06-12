import UIKit
import MapKit
import CoreLocation
import MobileCoreServices
import Contacts
import ContactsUI
import Photos
import AssetsLibrary

class NewMomentViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate,
        UIImagePickerControllerDelegate, UINavigationControllerDelegate, CNContactPickerDelegate {
    @IBOutlet weak var nameTextField: UITextField! { didSet { nameTextField.delegate = self } }
    @IBOutlet weak var descriptionTextField: UITextView!

    var timeline: Timeline?
    var pickedPhotoUrl: String?
    var pickedContact: String?
    
    
    private var locationManager: CLLocationManager!
    
    private var momentDao = MomentDao()
    private var locationDao = LocationDAO()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.becomeFirstResponder()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(save(_:)))
        
        initLocationManager()
    }
    
    @IBAction func showContactsAction() {
        let contactPickerViewController = CNContactPickerViewController()
        contactPickerViewController.delegate = self
        presentViewController(contactPickerViewController, animated: true, completion: nil)
    }

    func contactPicker(picker: CNContactPickerViewController, didSelectContact contact: CNContact) {
        //delegate.didFetchContacts([contact])
        print("contact picked: \(contact.familyName)")
        //navigationController?.popViewControllerAnimated(true)
        dismissViewControllerAnimated(true, completion: nil)
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
        self.testImage.image = image
        self.testImage.contentMode = .ScaleAspectFit
        
        let imageUrl = info[UIImagePickerControllerReferenceURL] as? NSURL
        print("image url: \(imageUrl?.absoluteString)")
        pickedPhotoUrl = imageUrl?.absoluteString
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // TODO diesen Code in Moment Details und auch in Moments-Tabelle
    func getUIImagefromAsseturl (url: NSURL) {
        let authorization = PHPhotoLibrary.authorizationStatus()
        print("photo library auth: \(authorization.rawValue)")

        let asset = PHAsset.fetchAssetsWithALAssetURLs([url], options: nil).firstObject as! PHAsset
        let fullTargetSize = CGSizeMake(-1, -1)
        let options = PHImageRequestOptions()
        
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: fullTargetSize, contentMode: PHImageContentMode.AspectFit, options: options, resultHandler: {
            (result, info) in
            print("fetched image with manager: \(result)")
            self.testImage.image = result
            self.testImage.contentMode = .ScaleAspectFit
        })
    }

    // TODO nur zu Testzwecken - Umbauen der gesamten View in eine statische Tabelle
    @IBOutlet weak var testImage: UIImageView!

    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func save(sender: AnyObject) {
        do {
            let momentEntity = try self.momentDao.createNewMomentEntity(forName: self.nameTextField.text!, withinTimeline: self.timeline!)
            momentEntity.descriptiontext = self.descriptionTextField.text
            
            if let currentLocation = self.locationManager.location {
                persistMomentWithWeatherAndCloseViewOnSuccess(forMoment: momentEntity, andCurrentLocation: currentLocation)
                
            } else {
                persistMomentAndCloseViewOnSuccess(momentEntity)
            }
            
        } catch MomentError.NameValidationError {
            showErrorMessage("Name must have at least 3 characters.")
        } catch {
            showErrorMessage("Could not create a new moment. Unexpected error occurred.")
        }
           
    }
    
    private func persistMomentWithWeatherAndCloseViewOnSuccess(forMoment moment: Moment, andCurrentLocation location: CLLocation) {
        print("current location: \(location)")
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        moment.location = locationDao.createNewWeatherEntity(withLatitude: latitude, andLongitude: longitude)

        // TODO nur zum Testen, später entfernen oder übernehmen, Async lib?
        checkReverseGeocode(forLatitude: latitude, andLongitude: longitude)
        
        WeatherService.sharedInstance.fetchWeather(forLatitude: latitude, andLongitude: longitude) {
            callback in
            
            if let error = callback.error {
                print("Weather data could't be fetched. Error code: \(error.code)")
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
    }

    private func persistMomentAndCloseViewOnSuccess(momentEntity: Moment) {
        let persistResult = self.momentDao.persistMoment(momentEntity)

        if let error = persistResult.error {
            self.showErrorMessage("Moment couldn't be saved. \(error.domain). Error code: \(error.code)") // TODO was soll dem Benutzer gezeigt werden?
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
