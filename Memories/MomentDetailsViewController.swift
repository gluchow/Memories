import UIKit

class MomentDetailsViewController: UIViewController {

    var moment: Moment? {
        didSet {
            print("MomentDetailsViewController moment didSet... moment: \(moment)")
            updateUI()
        }
    }
    
    @IBOutlet weak var nameLabelField: UILabel!
    @IBOutlet weak var descriptionLabelField: UILabel!
    @IBOutlet weak var creationDateLabelField: UILabel!
    
    @IBOutlet weak var weatherTemperatureLabelField: UILabel!
    @IBOutlet weak var weatherDescriptionLabelField: UILabel!
    @IBOutlet weak var latitudeLabelField: UILabel!
    @IBOutlet weak var longitudeLabelField: UILabel!
    
    @IBOutlet weak var countryLabelField: UILabel!
    @IBOutlet weak var locationNameLabelField: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Evtl. Nachladen aller benötigter Details
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
        latitudeLabelField?.text = nil
        longitudeLabelField?.text = nil
        countryLabelField?.text = nil
        locationNameLabelField?.text = nil
        
        if let moment = self.moment {
            nameLabelField?.text = moment.name
            descriptionLabelField?.text = moment.descriptiontext
            creationDateLabelField?.text = moment.creationDate?.description // TODO Formatter
            weatherDescriptionLabelField?.text = moment.weather?.descriptionText
            weatherTemperatureLabelField?.text = moment.weather?.temperature?.stringValue
            latitudeLabelField?.text = moment.location?.latitude?.stringValue
            longitudeLabelField?.text = moment.location?.longitude?.stringValue
            
            // TODO über Wetter-Service lassen? anderen Service einbinden zum Ermitteln des Ortnamens?
            countryLabelField?.text = moment.weather?.country
            locationNameLabelField?.text = moment.weather?.locationName
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
