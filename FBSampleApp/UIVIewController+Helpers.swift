//
//  Helpers.swift
//  SampleSwiftApp
//
//  Created by Eleftherios Charitou on 09/01/17.
//  Copyright © 2017 Anoxy Software. All rights reserved.
//

import UIKit

extension UIViewController {
    ///Helper function that shows an Alert Controller in a given viewController with a Title and message that has a completionHanlder to pass the button index of the button that was pressed
    ///Takes a variadic list of button titles so we can show as many buttons with any titles we need
    func showAlert(title:String, message: String, _ completionHandler:((_ buttonPressed: Int?) -> Void)?, buttonTitles:String...) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        for buttonTitle in buttonTitles {
            alertController.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: {(_ action: UIAlertAction) -> Void in
                let btnIndex = alertController.actions.index(of: action)
                completionHandler?(btnIndex)
            }))
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
}
