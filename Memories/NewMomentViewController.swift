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
        
        // TODO latitude und longitude des aktuellen Standorts ermitteln
        WeatherService.sharedInstance.fetchWeather(forLatitude: 47.8391, andLongitude: 12.1026) {
            callback in
            
            if let error = callback.error {
                print("Wetterdaten konnten nicht abgefragt werden. Fehler-Code: \(error.code)")
            }
            
            let momentEntity = self.momentDao.createNewMomentEntity(forName: self.nameTextField.text!, withinTimeline: self.timeline!)
            momentEntity.descriptiontext = self.descriptionTextField.text
            
            // TODO weitere Felder setzen
            
            let persistResult = self.momentDao.persistMoment(momentEntity)
            
            if let error = persistResult.error {
                self.showErrorMessage("Moment konnte nicht gespeichert werden. Fehler-Code: \(error.code)") // TODO was soll dem Benutzer gezeigt werden?
                return
            }
            
            // success, just close pop the top (current) view controller
            self.navigationController?.popViewControllerAnimated(true)
        }
        
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
