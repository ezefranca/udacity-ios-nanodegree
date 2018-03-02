//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Ezequiel França on 09/30/16.
//  Copyright © 2016 Ezequiel França All rights reserved.
//

import Foundation
import UIKit
import MapKit
import FBSDKLoginKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
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
                if success {
                    self.addAnnotationsToMap()
                } else {
                    self.errorAlert()
                }
            }
        }
    }
    
    func completeLogout() {
        FBSDKLoginManager().logOut()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addAnnotationsToMap() {
        
        var annotations = [MKPointAnnotation]()
        
        for location in ParseSessionVariables.sharedInstance().studentLocations {
            
            let lat = CLLocationDegrees(location.latitude)
            let long = CLLocationDegrees(location.longitude)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let mediaURL = location.mediaUrl
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = location.getFullName()
            annotation.subtitle = mediaURL
            
            annotations.append(annotation)
        }
        
        for annotation in mapView.annotations { mapView.removeAnnotation(annotation) }
        mapView.addAnnotations(annotations)
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
                    self.errorAlert()
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
                    self.errorAlert()
                }
            }
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                if let url = NSURL(string: toOpen) {
                    app.openURL(url)
                }
            }
        }
    }
    
    func errorAlert() {
        self.showGeneralAlert("Error", message: "Connection to server failed. Please try again", buttonTitle: "Ok")
    }
    
}