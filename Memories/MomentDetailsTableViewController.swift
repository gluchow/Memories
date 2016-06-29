import UIKit
import Photos
import AssetsLibrary
import CoreData

class MomentDetailsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    private let noValue = "-"
    private let momentDao = MomentDao()
    
    var moment: Moment? {
        didSet {
            print("MomentDetailsTableViewController moment didSet - moment: \(moment)")
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
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var creationDateLabel: UILabel!
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var showOnMapButton: UIButton!

    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    
    @IBOutlet weak var participantsTextView: UITextView!
    
    @IBOutlet weak var momentImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        performFetchResult()
    }
    
    private func performFetchResult() {
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
            nameLabel?.text = moment.name
            descriptionTextView?.text = moment.descriptiontext
            
            updateCreationDate()
            updateWeatherDetails()
            updateMomentImage()
            updateParticipants()
            updateLocation()
        }
    }
    
    private func resetFields() {
        nameLabel?.text = nil
        descriptionTextView?.text = nil
        creationDateLabel?.text = nil
        
        cityLabel?.text = nil
        countryLabel?.text = nil
        showOnMapButton?.enabled = false // initially deactivated
        
        temperatureLabel?.text = nil
        weatherDescriptionLabel?.text = nil
        
        participantsTextView?.text = nil
        momentImageView?.image = nil
    }
    
    private func updateCreationDate() {
        if let creationDate = Utils.dateString(moment?.creationDate) {
            creationDateLabel?.text = "Created on \(creationDate))"
        } else {
            creationDateLabel?.text = noValue
        }

    }

    private func updateLocation() {
        if !self.moment!.hasCoordinates() {
            showOnMapButton?.enabled = false
            cityLabel?.text = noValue
            countryLabel?.text = noValue
            return
        }
        
        showOnMapButton?.enabled = true
        cityLabel?.text = moment?.location?.city
        countryLabel?.text = moment?.location?.country
    }
    
    private func updateWeatherDetails() {
        weatherDescriptionLabel?.text = moment?.weather == nil ? noValue : moment?.weather?.descriptionText
        
        if let temperature = moment?.weather?.temperature {
            let formatter = NSNumberFormatter()
            formatter.numberStyle = .DecimalStyle
            formatter.maximumFractionDigits = 1
            temperatureLabel?.text = "\(formatter.stringFromNumber(temperature)!) °C"
        } else {
            temperatureLabel?.text = noValue
        }
    }
    
    private func updateParticipants() {
        if let contacts = moment?.contacts {
            participantsTextView?.text = contacts.joinWithSeparator("\n")
        } else {
            participantsTextView?.text = noValue
        }
    }
    
    // TODO zentral auslagern
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

    
    @IBAction func deleteMoment(sender: UIBarButtonItem) {
        if moment != nil {
            showRequestMessage("Do you really want to delete this moment?", type: .Warning, actionHandler: { (action: UIAlertAction!) in
                let response = self.momentDao.delete(self.moment!)
                if response.error != nil {
                    self.showMessage("Moment could not be deleted.", type: .Error)
                    return
                }
                
                self.navigationController?.popViewControllerAnimated(true)
            })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier != nil {
            
            switch(segue.identifier!) {
            case Storyboard.Segue.ShowEditMoment:
                let editMomentViewController = segue.destinationViewController as! EditMomentTableViewController
                editMomentViewController.moment = moment
                
            case Storyboard.Segue.ShowMomentOnMap:
                let momentMapViewController = segue.destinationViewController as! MomentMapViewController
                momentMapViewController.moment = moment
            default: break // nothing
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
