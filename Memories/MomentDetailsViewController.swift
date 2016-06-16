import UIKit
import Photos
import AssetsLibrary

class MomentDetailsViewController: UIViewController {

    var moment: Moment? {
        didSet {
            print("MomentDetailsViewController moment didSet... moment: \(moment)")
            updateUI()
        }
    }
    
    private let momentDao = MomentDao()
    
    @IBOutlet weak var nameLabelField: UILabel!
    @IBOutlet weak var descriptionLabelField: UILabel!
    @IBOutlet weak var creationDateLabelField: UILabel!
    
    @IBOutlet weak var weatherTemperatureLabelField: UILabel!
    @IBOutlet weak var weatherDescriptionLabelField: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    
    @IBOutlet weak var locationLabelField: UILabel!
    @IBOutlet weak var participantsLabelField: UILabel!
    
    @IBOutlet weak var momentImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("MomentDetailsViewController viewDidLoad()... moment: \(moment)")
        updateUI()
    }
    
    private func updateUI() {
        // reset
        nameLabelField?.text = nil
        descriptionLabelField?.text = nil
        creationDateLabelField?.text = nil
        weatherDescriptionLabelField?.text = nil
        weatherTemperatureLabelField?.text = nil
        locationLabelField?.text = nil
        participantsLabelField?.text = nil
        
        if let moment = self.moment {
            nameLabelField?.text = moment.name
            descriptionLabelField?.text = moment.descriptiontext
            creationDateLabelField?.text = moment.creationDate?.description // TODO Formatter
            
            updateWeatherDetails()
            updateLocation()
            updateMomentImage()
            updateParticipants()
        }
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
                print("photo library auth: \(authorization.rawValue)")
                
                let asset = PHAsset.fetchAssetsWithALAssetURLs([url], options: nil).firstObject as! PHAsset
                let fullTargetSize = CGSizeMake(-1, -1)
                let options = PHImageRequestOptions()
                
                PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: fullTargetSize, contentMode: PHImageContentMode.AspectFit, options: options, resultHandler: {
                    (result, info) in
                    print("fetched image with manager: \(result)")
                    self.momentImageView?.image = result
                    self.momentImageView?.contentMode = .ScaleAspectFit
                })
            }
        }
        
    }

}
