import UIKit

class MomentTableViewCell: UITableViewCell {

    var moment: Moment? {
        didSet {
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
        
        if let moment = self.moment {
            nameLabelField?.text = moment.name
            descriptionLabelField?.text = moment.descriptiontext
        }

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        // TODO benötigt?
    }

}
