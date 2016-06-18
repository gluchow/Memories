import UIKit
import Photos
import AssetsLibrary
import CoreData

class MomentDetailsViewController: UIViewController, NSFetchedResultsControllerDelegate {
    private let momentDao = MomentDao()
    
    var moment: Moment? {
        didSet {
            print("MomentDetailsViewController moment didSet... moment: \(moment)")
            updateUI()
        }
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: Moment.EntityName)
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest, managedObjectContext: self.momentDao.managedContext, sectionNameKeyPath: nil, cacheName: nil)

        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    @IBOutlet weak var nameLabelField: UILabel!
    @IBOutlet weak var descriptionLabelField: UILabel!
    @IBOutlet weak var creationDateLabelField: UILabel!
    
    @IBOutlet weak var weatherTemperatureLabelField: UILabel!
    @IBOutlet weak var weatherDescriptionLabelField: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    
    @IBOutlet weak var locationLabelField: UILabel!
    @IBOutlet weak var participantsLabelField: UILabel!
    
    @IBOutlet weak var momentImageView: UIImageView!
    
    @IBOutlet weak var mapButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad()")
        
        updateUI()
        
        // Performs fetch. Initializes fetchedResultsController and registering as delegate.
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
    }
   
    private func updateUI() {
        resetFields()

        if let moment = self.moment {
            nameLabelField?.text = moment.name
            descriptionLabelField?.text = moment.descriptiontext
            creationDateLabelField?.text = moment.creationDate?.description // TODO Formatter
            
            updateWeatherDetails()
            updateMomentImage()
            updateParticipants()
            updateLocation()
        }
    }
    
    private func resetFields() {
        nameLabelField?.text = nil
        descriptionLabelField?.text = nil
        creationDateLabelField?.text = nil
        weatherDescriptionLabelField?.text = nil
        weatherTemperatureLabelField?.text = nil
        locationLabelField?.text = nil
        participantsLabelField?.text = nil
        mapButton?.enabled = false // initially deactivated
    }

    @IBAction func deleteMoment(sender: UIBarButtonItem) {
        if moment != nil {
            showWarningAlert("Do you really want to delete this moment?", actionHandler: { (action: UIAlertAction!) in
                let response = self.momentDao.delete(self.moment!)
                if let error = response.error {
                    self.showErrorMessage("Moment could not be deleted. \(error.domain). Error code: \(error.code)")
                }
                
                self.navigationController?.popViewControllerAnimated(true)
            })
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier != nil {
            
            switch(segue.identifier!) {
            case Storyboard.Segue.ShowEditMoment:
                let editMomentViewController = segue.destinationViewController as! EditMomentViewController
                editMomentViewController.moment = moment
          
            case Storyboard.Segue.ShowMomentOnMap:
                let momentMapViewController = segue.destinationViewController as! MomentMapViewController
                momentMapViewController.moment = moment
            default: break // nothing
            }
            
        }
        
    }
    
    private func updateLocation() {
        if !self.moment!.hasCoordinates() {
            mapButton?.enabled = false
            locationLabelField?.text = "(no location)"
            return
        }
        
        mapButton?.enabled = true
        var locationString = ""
        
        if let locationName = moment?.weather?.locationName {
            locationString.appendContentsOf(locationName)
        }
        
        if let country = moment?.weather?.country {
            if locationString.characters.count > 0 {
                locationString.appendContentsOf(", ")
            }
            locationString.appendContentsOf(country)
        }
        
        locationLabelField?.text =  locationString
    }
    
    private func updateWeatherDetails() {
        if let descriptionText = moment?.weather?.descriptionText {
            weatherDescriptionLabelField?.text = descriptionText
        }
        
        if let temperature = moment?.weather?.temperature {
            weatherTemperatureLabelField?.text = temperature.stringValue // TODO Formatter für °C
        }
    }
    
    private func updateParticipants() {
        if let contacts = moment?.contacts {
            if contacts.isEmpty {
                participantsLabelField?.text = "(no participants)"
                
            } else {
                participantsLabelField?.text = contacts.joinWithSeparator(", ")
            }
        }
    }
    
    private func updateMomentImage() {
        if let urlString = moment?.imageUrl {
            if let url = NSURL(string: urlString) {
                let authorization = PHPhotoLibrary.authorizationStatus()
                print("photo library auth: \(authorization)")
                
                let asset = PHAsset.fetchAssetsWithALAssetURLs([url], options: nil).firstObject as! PHAsset
                let fullTargetSize = CGSizeMake(-1, -1)
                let options = PHImageRequestOptions()
                
                PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: fullTargetSize, contentMode: PHImageContentMode.AspectFit, options: options) {
                    (result, info) in
                    print("fetched image with manager: \(result)")
                    self.momentImageView?.image = result
                    self.momentImageView?.contentMode = .ScaleAspectFit
                }
            }
        }
        
    }
    
    
    // ------------------------------------------------------------------------------------------------------
    // MARK: NSFetchedResultsControllerDelegate
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject,
                    atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        print("controller ... didChangeObject ...")
        // Moment is registred to be monitored on changes. Changed object can only be a Moment-Instance.
        moment = anObject as? Moment
    }

}
