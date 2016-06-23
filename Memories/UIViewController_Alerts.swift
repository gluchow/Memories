import UIKit

extension UIViewController {
    typealias ActionHandler = (((UIAlertAction) -> Void)?)
    
    enum MessageType: String {
        case Error = "Error"
        case Info = "Info"
        case Warning = "Warning"
    }
    
    func showMessage(message: String, type: MessageType? = nil) {
        let alert = createAlert(message, type: type)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func showRequestMessage(message: String, type: MessageType?, actionHandler: ActionHandler) {
        let alert = createAlert(message, type: type)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: actionHandler))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    private func createAlert(message: String, type: MessageType?) -> UIAlertController {
        let title = type?.rawValue
        return UIAlertController(
            title: title,
            message: message,
            preferredStyle: .Alert)
    }
    
}
