import UIKit
import Photos
import AssetsLibrary

extension UIImageView {
    
    func loadImageFromLibrary(urlString: String, size: CGSize = CGSizeMake(-1, -1) , imageCallback callback: (UIImage?) -> ()) {
        if let url = NSURL(string: urlString) {
            let authorization = PHPhotoLibrary.authorizationStatus()
            print("photo library auth: \(authorization)")
            
            let asset = PHAsset.fetchAssetsWithALAssetURLs([url], options: nil).firstObject as! PHAsset
            let fullTargetSize = size
            let options = PHImageRequestOptions()
            
            PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: fullTargetSize, contentMode: PHImageContentMode.AspectFit, options: options) {
                (result, info) in
                print("Fetched image with manager: \(result)")
                if let image = result {
                    return callback(image)
                } else {
                    callback(nil)
                }
            }
        }
    }

}
