//
//  BaseViewController.swift
//  VirtualTourist
//
//  Created by Ezequiel França on 10/29/15.
//  Copyright © 2016 Ezequiel. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class BaseViewController: UIViewController {
    
    // Core data shared context
    var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance.managedObjectContext
    }()
    
    // save the context and handle the error if it occurrs
    func saveContext() {
        do {
            try CoreDataStackManager.sharedInstance.saveContext()
        } catch {
            showErrorAlert("Failed to save the information!")
        }
    }
}


extension BaseViewController {
    // show the error alert to the user
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:nil))
        presentViewController(alert, animated: true, completion: nil)
    }
}