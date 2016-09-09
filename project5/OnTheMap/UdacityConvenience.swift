//
//  UdacityConvenience.swift
//  OnTheMap
//
//  Created by Ezequiel França on 09/30/16.
//  Copyright © 2016 Ezequiel França All rights reserved.
//

import Foundation

extension UdacityClient {
    
    // MARK: GET convenience methods
    
    func getUserProfile(accountID: String, completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        let url = UdacityClient.subtituteKeyInMethod(Methods.UserProfile, key: "id", value: accountID)!
        
        taskForGETMethod(url, parameters: [:]) { JSONResult, error in
            if let error = error {
                completionHandler(success: false, error: error)
            } else if let response = UserInfoResponse(dictionary: JSONResult as! [String : AnyObject]) {
                // Store the user info including the accountID for later use
                response.accountID = accountID
                UdacitySessionVariables.sharedInstance().userInfo = response
                completionHandler(success: true, error: nil)
            } else {
                completionHandler(success: false, error: UdacityClient.createError("getUserProfile parsing", msg: "Could not parse getUserProfile"))
            }
        }
    }
    
    // MARK: POST convenience methods
    
    func postToCreateSession(username: String, password: String, completionHandler: (success: Bool, error: NSError?) -> Void) {

        let jsonBody : [String:AnyObject] = [
            UdacityClient.JSONBodyKeys.Udacity : [
                UdacityClient.JSONBodyKeys.Username: username,
                UdacityClient.JSONBodyKeys.Password: password
            ]
        ]
        
        taskForPOSTMethod(Methods.Session, parameters: [:], jsonBody: jsonBody) { JSONResult, error in
            
            if let error = error {
                completionHandler(success: false, error: error)
            } else {
                if let response = LoginResponse(dictionary: JSONResult as! [String: AnyObject]) {
                    self.getUserProfile(response.accountId!) { success, error in
                        if success {
                            completionHandler(success: true, error: nil)
                        } else {
                            completionHandler(success: false, error: error)
                        }
                    }
                } else if let errorResponse = ErrorLoginResponse(dictionary: JSONResult as! [String: AnyObject]) {
                    completionHandler(success: false, error: UdacityClient.createError("login error", msg: errorResponse.errorMsg!))
                } else {
                    completionHandler(success: false, error: UdacityClient.createError("postToCreateSession parsing", msg: "Could not parse postToCreateSession"))
                }
            }
        }
    }
    
    func postToCreateFacebookSession(accessToken: String, completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        let jsonBody : [String:AnyObject] = [
            UdacityClient.JSONBodyKeys.FacebookMobile : [
                UdacityClient.JSONBodyKeys.AccessToken: accessToken
            ]
        ]
        
        taskForPOSTMethod(Methods.Session, parameters: [:], jsonBody: jsonBody) { JSONResult, error in
            
            if let error = error {
                completionHandler(success: false, error: error)
            } else {
                if let response = LoginResponse(dictionary: JSONResult as! [String: AnyObject]) {
                    self.getUserProfile(response.accountId!) { success, error in
                        if success {
                            completionHandler(success: true, error: nil)
                        } else {
                            completionHandler(success: false, error: error)
                        }
                    }
                } else {
                    completionHandler(success: false, error: UdacityClient.createError("postToCreateFacebookSession parsing", msg: "Could not parse postToCreateFacebookSession"))
                }
            }
        }
    }
    
    // MARK: DELETE convenience methods
    
    func deleteToLogout(completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        /* Build the URL and configure the request */
        let urlString = Constants.BaseURL + Methods.Session
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        
        if let xsrfCookie = xsrfCookie {
            request.addValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        /* Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                let newError = UdacityClient.errorForData(data, response: response, error: error)
                completionHandler(success: false, error: newError)
            } else {
                let processedData = self.specialProcessing(data!)
                UdacityClient.parseJSONWithCompletionHandler(processedData) { JSONResult, error in
                    if let _ = LogoutResponse(dictionary: JSONResult as! [String: AnyObject]) {
                        completionHandler(success: true, error: nil)
                    } else {
                        completionHandler(success: false, error: UdacityClient.createError("deleteToLogout parsing", msg: "Could not parse deleteToLogout"))
                    }
                }
            }
        }
        
        /* Start the request */
        task.resume()
    }
    
}