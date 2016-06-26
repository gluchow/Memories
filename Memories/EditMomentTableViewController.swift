import UIKit
import MapKit
import CoreLocation
import MobileCoreServices
import Contacts
import ContactsUI


class EditMomentTableViewController: UITableViewController, UITextFieldDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CNContactPickerDelegate {
    
    var timeline: Timeline?
    var moment: Moment? // TODO didSet?
    
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
    
    @IBOutlet weak var nameTextField: UITextField! // TODO delegate für textfield
    @IBOutlet weak var participantsTextView: UITextView!
    @IBOutlet weak var momentImage: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
        initLocationManager()

        nameTextField.becomeFirstResponder()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(save(_:)))
    }
    
    
    @IBAction func takePhoto(sender: UIButton) {
         print("take photo")
        // TODO
    }
    
    @IBAction func chooseImageFromLib(sender: UIButton) {
        print("choose image from lib")
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) { // TODO wieder zurück auf .Camera (nicht im Simulator möglich)
            let picker = UIImagePickerController()
            picker.sourceType = .PhotoLibrary // TODO wieder zurück auf .Camera (nicht im Simulator möglich)
            picker.mediaTypes = [kUTTypeImage as String] // TODO prüfen, ob das so i.O. ist
            picker.delegate = self
            picker.allowsEditing = true
            presentViewController(picker, animated: true, completion: nil)
        }
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
    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         // self.navigationItem.rightBarButtonItem = self.editButtonItem()
//    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        print("canEditRowAtIndexPath: section \(indexPath.section)")
        print("canEditRowAtIndexPath: row \(indexPath.row)")
        return true
    }
    
//    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        
//        return UITableViewAutomaticDimension
//    }
    
    
    
    private func updateUI() {
        print("updateUI()")
        if moment != nil {
            nameTextField?.text = moment?.name
            descriptionTextView?.text = moment?.descriptiontext
            pickedImageUrl = moment?.imageUrl
            if let contacts = moment?.contacts {
                pickedParticipants = contacts
            }
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
        
        // TODO auslagern in service
        // Async fetch location name for given lat/lon
        CLGeocoder().reverseGeocodeLocation(location) {
            (placemarks, error) -> Void in
            print(location)
            
            if error != nil {
                print("Error in reverse geocoder: " + error!.localizedDescription)
            }
            
            if placemarks!.count > 0 {
                let placemark = placemarks![0]
                print("Reverse geocoder - Placemark gefunden: ")
                print(placemark.country)
                print(placemark.locality)
                
                // Update location entity
                self.moment?.location?.city = placemark.locality
                self.moment?.location?.country = placemark.country
                self.moment?.location?.moment = self.moment
                
            }
            else {
                print("No Data from reverse geocoder received.")
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
        self.momentImage.image = image
        self.momentImage.contentMode = .ScaleAspectFit
        
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
    
    
    
    
    
    
    
    
    

    // MARK: - Table view data source
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
//    {
//        print("cellForRowAtIndexPath. section: \(indexPath.section)")
//        if indexPath.section == Section.BasicData {
//            print("show basic data...")
//            var cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.Identifier.EditMomentBasicDataCell) as? MomentBaiscDataTableViewCell
//            if cell == nil {
//                cell = MomentBaiscDataTableViewCell()
//            }
//            print("basic cell: \(cell)")
//            cell?.moment = moment
//            return cell!
//            
//        } else if indexPath.section == Section.Image {
//            var cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.Identifier.EditMomentImageCell)
//            if cell == nil {
//                cell = UITableViewCell()
//            }
//            cell?.textLabel?.text = "asdf"
//            return cell!
//            
//        } else if indexPath.section == Section.Participants {
//            var cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.Identifier.EditMomentParticipantsCell) as? MomentParticipantsTableViewCell
//            if cell == nil {
//                cell = MomentParticipantsTableViewCell()
//            }
//            cell?.moment = moment
//            return cell!
//        
//        } else {
//            print("Unhandled Section ID: \(indexPath.section).")
//            abort()
//        }
//
//    }
    
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
//    {
//        return 1
//    }
    
//    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
//    {
//        return Section.Title[section]
//    }
//    
//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
//    {
//        return Section.Title.count
//    }
//    


  /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
