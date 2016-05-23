import UIKit

class NewMomentViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var nameTextField: UITextField! { didSet { nameTextField.delegate = self } }
    @IBOutlet weak var descriptionTextField: UITextView!

    
    // TODO so okay? anfangs noch nicht gesetzt. für save() 
    var timeline: Timeline?

    private var momentDao = MomentDao()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.becomeFirstResponder()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(save(_:)))
    }
    
    func save(sender: AnyObject) {
        let momentEntity = momentDao.createNewMomentEntity(forName: nameTextField.text!, withinTimeline: timeline!)
        momentEntity.descriptiontext = descriptionTextField.text
        // TODO weitere Felder setzen
        
        let persistResult = momentDao.persistMoment(momentEntity)
        
        if let error = persistResult.error {
            showErrorMessage("Moment could not be saved. Error code: \(error.code)") // TODO was soll dem Benutzer gezeigt werden?
        }
        
        // success, just close pop the top (current) view controller
        navigationController?.popViewControllerAnimated(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == nameTextField {
            textField.resignFirstResponder()
            // TODO auslesen..
        }
        // TODO Beschreibungsfeld auslesen?
       
        return true
    }
    
}
