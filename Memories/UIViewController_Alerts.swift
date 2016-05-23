//
//  UIViewController_Alerts.swift
//  Memories
//
//  Created by admin on 22.05.16.
//  Copyright © 2016 gluglu. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showErrorMessage(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
}
