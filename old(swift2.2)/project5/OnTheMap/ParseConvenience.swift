//
//  ParseConvenience.swift
//  OnTheMap
//
//  Created by Ezequiel França on 09/30/16.
//  Copyright © 2016 Ezequiel França All rights reserved.
//

import Foundation

extension ParseClient {
    
    // MARK: GET convenience methods
    
    func getStudentLocations(limit: Int, completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        let parameters: [String: AnyObject] = [
            ParameterKeys.Limit : limit,
            ParameterKeys.Skip : 0,
            ParameterKeys.Order : "-\(JSONResponseKeys.UpdatedAt)"
        ]
        
        taskForGETMethod(Methods.StudentLocation, parameters: parameters) { JSONResult, error in
            if let error = error {
                // ERROR
                completionHandler(success: false, error: error)
            } else if let results = JSONResult{
                
                let result = results.valueForKey(JSONResponseKeys.Results) as? [[String:AnyObject]]
                print(result)
                // SUCCESS
                ParseSessionVariables.sharedInstance().studentLocations = StudentLocationResponse.parseResponseList(result!)
                completionHandler(success: true, error: nil)
            } else {
                // PARSING ERROR
                completionHandler(success: false, error: UdacityClient.createError("getUserProfile parsing", msg: "Could not parse getUserProfile"))
            }
        }
    }
    
    func getQueryStudentLocation(completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        let userAccountId = UdacitySessionVariables.sharedInstance().userInfo!.accountID
        let parameters: [String: AnyObject] = [
            ParameterKeys.Where : "{\"\(ParameterKeys.UniqueKey)\":\"\(userAccountId)\"}"
        ]
        
        taskForGETMethod(Methods.StudentLocation, parameters: parameters) { JSONResult, error in
            if let error = error {
                // ERROR
                completionHandler(success: false, error: error)
            } else if let results = JSONResult.valueForKey(JSONResponseKeys.Results) as? [[String:AnyObject]] {
                // SUCCESS
                if let studentLocation = StudentLocationResponse.parseResponseList(results).first {
                    ParseSessionVariables.sharedInstance().studentLocationId = studentLocation.objectId
                }
                completionHandler(success: true, error: nil)
            } else {
                // PARSING ERROR
                completionHandler(success: false, error: UdacityClient.createError("getUserProfile parsing", msg: "Could not parse getUserProfile"))
            }
        }
    }
    
    // MARK: POST convenience methods
    
    func postToCreateStudentLocation(mapString: String, mediaUrl: String, latitude: Double, longitude: Double, completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        let jsonBody : [String:AnyObject] = [
            ParseClient.JSONBodyKeys.FirstName : UdacitySessionVariables.sharedInstance().userInfo!.firstName,
            ParseClient.JSONBodyKeys.LastName : UdacitySessionVariables.sharedInstance().userInfo!.lastName,
            ParseClient.JSONBodyKeys.UniqueKey : UdacitySessionVariables.sharedInstance().userInfo!.accountID,
            ParseClient.JSONBodyKeys.MapString : mapString,
            ParseClient.JSONBodyKeys.MediaUrl : mediaUrl,
            ParseClient.JSONBodyKeys.Latitude : latitude,
            ParseClient.JSONBodyKeys.Longitude : longitude
        ]
        
        taskForPOSTMethod(Methods.StudentLocation, parameters: [:], jsonBody: jsonBody) { JSONResult, error in
            
            if let error = error {
                // ERROR
                completionHandler(success: false, error: error)
            } else if let response = CreateLocationResponse(dictionary: JSONResult as! [String: AnyObject]) {
                // SUCCESS
                ParseSessionVariables.sharedInstance().studentLocationId = response.objectId
                completionHandler(success: true, error: nil)
            } else {
                // PARSING ERROR
                completionHandler(success: false, error: UdacityClient.createError("postToCreateStudentLocation parsing", msg: "Could not parse postToCreateStudentLocation"))
            }
        }
    }
    
    // MARK: PUT convenience methods
    
    func putToModifyStudentLocation(mapString: String, mediaUrl: String, latitude: Double, longitude: Double, completionHandler: (success: Bool, error: NSError?) -> Void) {
        let jsonBody : [String:AnyObject] = [
            ParseClient.JSONBodyKeys.MapString : mapString,
            ParseClient.JSONBodyKeys.MediaUrl : mediaUrl,
            ParseClient.JSONBodyKeys.Latitude : latitude,
            ParseClient.JSONBodyKeys.Longitude : longitude
        ]
        
        let url = ParseClient.subtituteKeyInMethod(Methods.ModifyStudentLocation, key: "id", value: ParseSessionVariables.sharedInstance().studentLocationId!)!
        
        taskForPUTMethod(url, parameters: [:], jsonBody: jsonBody) { JSONResult, error in
            
            if let error = error {
                // ERROR
                completionHandler(success: false, error: error)
            } else if let _ = ModifyLocationResponse(dictionary: JSONResult as! [String: AnyObject]) {
                // SUCCESS
                completionHandler(success: true, error: nil)
            } else {
                // PARSING ERROR
                completionHandler(success: false, error: ParseClient.createError("putToModifyStudentLocation parsing", msg: "Could not parse putToModifyStudentLocation"))
            }
        }
        
    }
    
}