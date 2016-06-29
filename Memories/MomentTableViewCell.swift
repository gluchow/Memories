import UIKit
import Photos
import AssetsLibrary

class MomentTableViewCell: UITableViewCell {

    var moment: Moment? {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var momentImageView: UIImageView!
    
    
    private func updateUI() {
        resetFields()
        
        if let moment = self.moment {
            nameLabel?.text = moment.name
            descriptionLabel?.text = moment.descriptiontext
            updateInfoField()
            updateMomentImage()
        }

    }
    
    private func resetFields() {
        nameLabel?.text = nil
        descriptionLabel?.text = nil
        momentImageView?.image = nil
        infoLabel?.text = nil
    }
    
    private func updateInfoField() {
        if let moment = self.moment {
            var infoText = ""
            if let creationDate = Utils.dateString(moment.creationDate) {
                infoText.appendContentsOf(creationDate)
            }
            if !moment.locationString.characters.isEmpty {
                infoText.appendContentsOf(", ")
                infoText.appendContentsOf(moment.locationString)
            }
            infoLabel?.text = infoText
        }
    }
    
    private func updateMomentImage() {
        if let urlString = moment?.imageUrl {
            momentImageView?.loadImageFromLibrary(urlString, size: CGSizeMake(75, 75)) {
                image in
                self.momentImageView?.image = image
                self.momentImageView?.contentMode = .ScaleAspectFit
            }
        }
    }

}
