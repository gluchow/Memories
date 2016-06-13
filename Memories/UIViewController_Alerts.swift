import UIKit

extension UIViewController {
    
    typealias ActionHandler = (((UIAlertAction) -> Void)?)
    
    
    func showErrorMessage(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func showWarningAlert(message: String, actionHandler: ActionHandler) {
        let warningAlert = UIAlertController(
            title: "Warning",
            message: message,
            preferredStyle: UIAlertControllerStyle.Alert)
        
        warningAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: actionHandler))
        warningAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        presentViewController(warningAlert, animated: true, completion: nil)
        
    }
    
}
