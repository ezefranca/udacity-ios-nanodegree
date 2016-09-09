//
//  MemeMeTextFieldDelegate.swift
//  MemeMe
//
//  Created by Ezequiel França on 7/31/16.
//  Copyright © 2016 Ezequiel França. All rights reserved.
//

import Foundation
import UIKit


class MemeMeTextFieldDelegate : NSObject, UITextFieldDelegate {
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField.text! == "BOTTOM" || textField.text! == "TOP"){
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
