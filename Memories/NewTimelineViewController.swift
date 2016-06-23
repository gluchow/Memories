import UIKit

class NewTimelineViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.becomeFirstResponder()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(save(_:)))
    }
    
    func save(sender: AnyObject) {
        let result = TimelineDao().persistTimeline(forName: nameTextField.text!, andDescription: descriptionTextField.text)
        if result.error != nil {
            showMessage("Timeline could not be saved.", type: .Error)
            return
        }
        navigationController?.popViewControllerAnimated(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
