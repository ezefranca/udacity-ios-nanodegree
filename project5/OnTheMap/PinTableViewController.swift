//
//  PinTableViewController.swift
//  OnTheMap
//
//  Created by Ezequiel França on 09/30/16.
//  Copyright © 2016 Ezequiel França All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit

class PinTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var studentLocationOverwriting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch the students locations if we havent already
        getStudentLocations()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationVC = segue.destinationViewController as? PinLocationViewController {
            destinationVC.isOvewriting = studentLocationOverwriting
        }
    }
    
    func getStudentLocations() {
        ParseClient.sharedInstance().getStudentLocations(100) { success, error in
            dispatch_async(dispatch_get_main_queue()) {
                if success { self.tableView.reloadData() }
                else {
                    self.showGeneralAlert("Error", message: "Connection to server failed. Tap refresh to try again", buttonTitle: "Ok")
                }
            }
        }
    }
    
    func completeLogout() {
        FBSDKLoginManager().logOut()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func checkPinAndAdd() {
        if let _ = ParseSessionVariables.sharedInstance().studentLocationId {
            studentLocationOverwriting = true
            showOverrideAlert()
        } else {
            studentLocationOverwriting = false
            gotoPostPin()
        }
    }
    
    func gotoPostPin() {
        performSegueWithIdentifier("postPin", sender: self)
    }
    
    func showOverrideAlert() {
        
        let msg = "You Have Already Posted a Student Location. Would You Like to Overwrite Your Current Location?"
        let alert = UIAlertController(title: "", message: msg, preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        let overrideAction = UIAlertAction(title: "Overwrite", style: .Default) { action in
            self.gotoPostPin()
        }
        
        alert.addAction(overrideAction)
        alert.addAction(dismissAction)
        
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    // MARK: Actions
    
    @IBAction func refreshAction(sender: UIBarButtonItem) {
        getStudentLocations()
    }
    
    @IBAction func addPinAction(sender: UIBarButtonItem) {
        SpecialActivityIndicator.sharedInstance().show(view, msg: "Checking..")
        ParseClient.sharedInstance().getQueryStudentLocation() { success, error in
            dispatch_async(dispatch_get_main_queue()) {
                SpecialActivityIndicator.sharedInstance().hide()
                
                if success { self.checkPinAndAdd() }
                else {
                    self.showGeneralAlert("Error", message: "Connection to server failed. Please try again", buttonTitle: "Ok")
                }
            }
        }
    }
    
    @IBAction func logoutAction(sender: UIBarButtonItem) {
        SpecialActivityIndicator.sharedInstance().show(view, msg: "Loggin out")
        UdacityClient.sharedInstance().deleteToLogout() { success, error in
            dispatch_async(dispatch_get_main_queue()) {
                SpecialActivityIndicator.sharedInstance().hide()
                
                if success { self.completeLogout() }
                else {
                    self.showGeneralAlert("Error", message: "Connection to server failed. Please try again", buttonTitle: "Ok")
                }
            }
        }
    }
}

extension PinTableViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("pinTableCell") as! PinTableViewCell
        cell.nameLabel.text = ParseSessionVariables.sharedInstance().studentLocations[indexPath.row].getFullName()
        cell.urlLabel.text = ParseSessionVariables.sharedInstance().studentLocations[indexPath.row].mediaUrl
        
        cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.groupTableViewBackgroundColor() : UIColor.whiteColor()
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ParseSessionVariables.sharedInstance().studentLocations.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let toOpen = ParseSessionVariables.sharedInstance().studentLocations[indexPath.row].mediaUrl
        UIApplication.sharedApplication().openURL(NSURL(string: toOpen)!)
    }

}