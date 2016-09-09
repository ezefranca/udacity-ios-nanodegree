//
//  PinLocationViewController.swift
//  OnTheMap
//
//  Created by Ezequiel França on 09/30/16.
//  Copyright © 2016 Ezequiel França All rights reserved.
//

import Foundation
import UIKit
import MapKit

class PinLocationViewController: UIViewController {
    
    @IBOutlet weak var mapStringField: UITextField!
    @IBOutlet weak var mediaUrlField: UITextField!
    @IBOutlet weak var firstStepView: UIView!
    @IBOutlet weak var secondStepView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var cancel2Button: UIButton!
    @IBOutlet weak var findButton: UIButton!
    
    var coords: CLLocationCoordinate2D?
    var mapString: String = ""
    var mediaUrl: String = ""
    var isOvewriting: Bool = false
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        firstStepView.hidden = false
        secondStepView.hidden = true
        
        mapStringField.delegate = self
        mediaUrlField.delegate = self
        
        addKeyboardGestureRecognizer()
    }
    
    func blockButtons(block: Bool) {
        submitButton.enabled = !block
        submitButton.userInteractionEnabled = !block
        
        findButton.enabled = !block
        findButton.userInteractionEnabled = !block
        
        cancelButton.enabled = !block
        cancelButton.userInteractionEnabled = !block
        
        cancel2Button.enabled = !block
        cancel2Button.userInteractionEnabled = !block
    }
    
    func showMap() {
        if let pinLocation = coords {
            // SHOW PIN ON MAP
            let annotation = MKPointAnnotation()
            let newCamera = MKMapCamera(lookingAtCenterCoordinate: pinLocation, fromEyeCoordinate: pinLocation, eyeAltitude: CLLocationDistance(2000.0))
            annotation.coordinate = pinLocation
            mapView.addAnnotation(annotation)
            mapView.setCamera(newCamera, animated: true)
            mapView.userInteractionEnabled = false
            
            firstStepView.hidden = true
            secondStepView.hidden = false
            
        } else {
            // ERROR GETTING LOCATION
            showGeneralAlert("Error", message: "Forward geocoding failed", buttonTitle: "Try Again")
        }
    }
    
    func createStudentLocation() {
        SpecialActivityIndicator.sharedInstance().show(view, msg: "Sending..")
        blockButtons(true)
        ParseClient.sharedInstance().postToCreateStudentLocation(mapString, mediaUrl: mediaUrl, latitude: coords!.latitude, longitude: coords!.longitude) { success, error in
            dispatch_async(dispatch_get_main_queue()) {
                SpecialActivityIndicator.sharedInstance().hide()
                self.blockButtons(false)
                
                if success {
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else  {
                    self.showGeneralAlert("Error", message: "Posting student location failed. Please try again", buttonTitle: "Ok")
                }
            }
        }
    }
    
    func overrideStudentLocation() {
        SpecialActivityIndicator.sharedInstance().show(view, msg: "Sending..")
        blockButtons(true)
        ParseClient.sharedInstance().putToModifyStudentLocation(mapString, mediaUrl: mediaUrl, latitude: coords!.latitude, longitude: coords!.longitude) { success, error in
            dispatch_async(dispatch_get_main_queue()) {
                SpecialActivityIndicator.sharedInstance().hide()
                self.blockButtons(false)
                
                if success {
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else  {
                    self.showGeneralAlert("Error", message: "Overwriting student location failed. Please try again", buttonTitle: "Ok")
                }
            }
        }
    }
    
    // MARK: Actions
    
    @IBAction func cancelAction(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func findOnMapAction(sender: UIButton) {
        
        // Check empty field
        mapString = mapStringField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if mapString.isEmpty {
            // ERROR EMPTY LOCATION FIELD
            showGeneralAlert("Error", message: "Location field is empty", buttonTitle: "Ok")
            return
        }
        
        SpecialActivityIndicator.sharedInstance().show(view, msg: "Geocoding")
        blockButtons(true)
        CLGeocoder().geocodeAddressString(mapString) {
            (placemarks, error) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                SpecialActivityIndicator.sharedInstance().hide()
                self.blockButtons(false)
                
                if let error = error {
                    self.showGeneralAlert("Error", message: "Forward geocoding failed: \(error.localizedDescription)", buttonTitle: "Ok")
                } else if placemarks!.count > 0 {
                    let placemark = placemarks![0]
                    let location = placemark.location
                    self.coords = location?.coordinate
                    self.showMap()
                }
            }
        }
    }
    
    @IBAction func submitAction(sender: UIButton) {
        // Check empty field
        mediaUrl = mediaUrlField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if mediaUrl.isEmpty {
            // ERROR EMPTY LOCATION FIELD
            showGeneralAlert("Error", message: "Media url field is empty", buttonTitle: "Ok")
            return
        }
        
        if isOvewriting { overrideStudentLocation() }
        else { createStudentLocation() }
    }
}

extension PinLocationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide keyboard
        textField.resignFirstResponder()
        
        return true
    }
}
