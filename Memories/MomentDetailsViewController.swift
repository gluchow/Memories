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
        
        if let moment = self.moment {
            nameLabelField?.text = moment.name
            descriptionLabelField?.text = moment.descriptiontext
            creationDateLabelField?.text = moment.creationDate?.description // TODO Formatter
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
