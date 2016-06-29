import UIKit
import MapKit
import CoreLocation
import MobileCoreServices
import Contacts
import ContactsUI


class EditMomentTableViewController: UITableViewController, UITextFieldDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CNContactPickerDelegate {
    
    var timeline: Timeline?
    var moment: Moment?
    
    var pickedImageUrl: String?
    var pickedParticipants = [String]() {
        didSet {
            updateParticipantsUI()
        }
    }
    
    private var locationManager: CLLocationManager!
    private var momentDao = MomentDao()
    private var locationDao = LocationDAO()
    
    private struct Section {
        static let BasicData = 0
        static let Image = 1
        static let Participants = 2
        
        static let Title = ["Basic Data", "Image", "Participants"]
    }
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var participantsTextView: UITextView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var momentImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
        initLocationManager()

        nameTextField.becomeFirstResponder()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(save(_:)))
    }
    
    
    @IBAction func takePhoto(sender: UIButton) {
         print("take photo")
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            showImagePicker(.Camera)
        } else {
            showMessage("Camera is not available.")
        }
    }
    
    @IBAction func chooseImageFromLib(sender: UIButton) {
        print("choose image from lib")
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            showImagePicker(.PhotoLibrary)
        } else {
            showMessage("Image library is not available.")
        }
    }
    
    private func showImagePicker(type: UIImagePickerControllerSourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = type
        picker.mediaTypes = [kUTTypeImage as String]
        picker.delegate = self
        picker.allowsEditing = true
        presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func addFromContacts(sender: UIButton) {
         print("add from contacts")
        let contactPickerViewController = CNContactPickerViewController()
        contactPickerViewController.delegate = self
        presentViewController(contactPickerViewController, animated: true, completion: nil)
    }
    
    @IBAction func clearPickedContacts(sender: AnyObject) {
        pickedParticipants.removeAll()
    }
    
    private func updateParticipantsUI() {
        participantsTextView?.text = pickedParticipants.joinWithSeparator("\n")
    }
    
    private func updateUI() {
        print("updateUI()")
        if moment != nil {
            nameTextField?.text = moment?.name
            descriptionTextView?.text = moment?.descriptiontext
            pickedImageUrl = moment?.imageUrl
            if let contacts = moment?.contacts {
                pickedParticipants = contacts
            }
            updateMomentImage()
        }
    }
    
    func save(sender: AnyObject) {
        if moment != nil { // Moment exists already because it is being edited
            persistMomentAndCloseViewOnSuccess()
            
        } else {
            createNewMomentEntity()
        }
    }
    
    private func createNewMomentEntity() {
        do {
            moment = try self.momentDao.createNewMomentEntity(forName: self.nameTextField.text!, withinTimeline: self.timeline!)
            moment?.descriptiontext = self.descriptionTextView.text
            
            if let currentLocation = self.locationManager.location {
                persistMomentWithWeatherAndCloseViewOnSuccess(currentLocation: currentLocation)
                
            } else {
                persistMomentAndCloseViewOnSuccess()
            }
            
        } catch MomentError.NameValidationError(let message) {
            showMessage(message)
            
        } catch {
            showMessage("Could not create a new moment. Unexpected error occurred.", type: MessageType.Error)
            
        }
    }
    
    private func persistMomentWithWeatherAndCloseViewOnSuccess(currentLocation location: CLLocation) {
        print("current location: \(location)")
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        // Async fetch of weather data
        WeatherService.sharedInstance.fetchWeather(forLatitude: latitude, andLongitude: longitude) {
            callback in
            
            if let error = callback.error {
                print("Weather data could't be fetched. Error: \(error.localizedDescription)")
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
            }
            
            if placemarks?.count > 0 {
                let placemark = placemarks![0]
                print("Reverse geocoder - placemark found: \(placemark.country), \(placemark.locality))")
                
                // Update location entity
                self.moment?.location?.city = placemark.locality
                self.moment?.location?.country = placemark.country
                self.moment?.location?.moment = self.moment
                
            }
            else {
                print("Location not found. No data received from reverse geocoder.")
            }
            
            self.persistMomentAndCloseViewOnSuccess()
        }
        
    }
    
    private func persistMomentAndCloseViewOnSuccess() {
        if moment == nil {
            return
        }
        
        moment!.name = nameTextField.text
        moment!.descriptiontext = descriptionTextView.text
        moment!.contacts = pickedParticipants
        moment!.imageUrl = pickedImageUrl
        
        let persistResult = self.momentDao.persistMoment(self.moment!)
        
        if persistResult.error != nil {
            self.showMessage("Moment couldn't be saved.", type: MessageType.Error)
            return
        }
        
        // success, just close pop the top (current) view controller
        self.navigationController?.popViewControllerAnimated(true)
    }

    private func initLocationManager() {
        if (CLLocationManager.locationServicesEnabled()) {
            print("Location service is enabled")
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    private func updateMomentImage() {
        if let urlString = moment?.imageUrl {
            momentImageView?.loadImageFromLibrary(urlString) {
                image in
                self.momentImageView?.image = image
                self.momentImageView?.contentMode = .ScaleAspectFit
            }
        }
    }
    
    // ------------------------------------------------------------------------------------------------------
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == nameTextField {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    
    // ------------------------------------------------------------------------------------------------------
    // MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        self.momentImageView.image = image
        self.momentImageView.contentMode = .ScaleAspectFit
        
        let imageUrl = info[UIImagePickerControllerReferenceURL] as? NSURL
        print("image url: \(imageUrl?.absoluteString)")
        self.pickedImageUrl = imageUrl?.absoluteString
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // ------------------------------------------------------------------------------------------------------
    // MARK: CNContactPickerDelegate
    
    func contactPicker(picker: CNContactPickerViewController, didSelectContact contact: CNContact) {
        pickedParticipants.append("\(contact.givenName) \(contact.familyName)")
        dismissViewControllerAnimated(true, completion: nil)
    }

}
