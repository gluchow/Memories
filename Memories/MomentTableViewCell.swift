import UIKit

class MomentTableViewCell: UITableViewCell {

    // TODO public API -> Moment Object
    var moment: Moment? {
        didSet {
            print("MomentTableViewCell - moment didSet... moment: \(moment)")
            // TODO zu früh, label fields könnten noch nicht da sein
            updateUI()
        }
    }
    
    @IBOutlet weak var nameLabelField: UILabel!
    @IBOutlet weak var momentImage: UIImageView!
    @IBOutlet weak var descriptionLabelField: UILabel!
    
    private func updateUI() {
        // reset
        nameLabelField?.text = nil
        descriptionLabelField?.text = nil
        momentImage?.image = nil
        
        // TODO prüfen, ob das sein muss
        if let moment = self.moment {
            nameLabelField?.text = moment.name
            descriptionLabelField?.text = moment.descriptiontext
        }

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        print("MomentTableViewCell selected...")
    }

}
