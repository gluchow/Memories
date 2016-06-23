import UIKit
import Photos
import AssetsLibrary

class MomentTableViewCell: UITableViewCell {

    var moment: Moment? {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet weak var nameLabelField: UILabel!
    @IBOutlet weak var momentImage: UIImageView!
    @IBOutlet weak var descriptionLabelField: UILabel!
    @IBOutlet weak var infoField: UILabel!
    
    private func updateUI() {
        resetFields()
        
        if let moment = self.moment {
            nameLabelField?.text = moment.name
            descriptionLabelField?.text = moment.descriptiontext
            updateInfoField()
            updateMomentImage()
        }

    }
    
    private func resetFields() {
        nameLabelField?.text = nil
        descriptionLabelField?.text = nil
        momentImage?.image = nil
        infoField?.text = nil
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
            infoField?.text = infoText
        }
    }

    private func updateMomentImage() {
        if let urlString = moment?.imageUrl {
            if let url = NSURL(string: urlString) {
                let authorization = PHPhotoLibrary.authorizationStatus()
                print("photo library auth: \(authorization)")
                
                let asset = PHAsset.fetchAssetsWithALAssetURLs([url], options: nil).firstObject as! PHAsset
                let fullTargetSize = CGSizeMake(75, 75)
                let options = PHImageRequestOptions()
                
                PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: fullTargetSize, contentMode: PHImageContentMode.AspectFit, options: options) {
                    (result, info) in
                    print("fetched image with manager: \(result)")
                    self.imageView?.image = result
                    self.imageView?.contentMode = .ScaleAspectFit
                }
            }
        }
        
    }

}
