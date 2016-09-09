//
//  APIClient.swift
//  OnTheMap
//
//  Created by Ezequiel França on 09/30/16.
//  Copyright © 2016 Ezequiel França All rights reserved.
//

import Foundation

class APIClient: NSObject {
    
    static let ErrorKey = "error"
    
    /* Shared session */
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    /* Function to set headers in any subclass */
    func getCommonHeaders() -> [String: String] {
        return [:]
    }
    
    /* Function to set base url in any subclass */
    func getBaseUrl() -> String {
        return ""
    }
    
    
    // MARK: - Helper
    
    func taskForMethod(httpMethod: String, method: String, parameters: [String : AnyObject], jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* Build the URL and configure the request */
        let urlString = getBaseUrl() + method + ParseClient.escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        if httpMethod != "GET" {
            request.HTTPMethod = httpMethod
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: NSJSONWritingOptions(rawValue: 0))
        }
        
        for (headerKey, headerValue) in getCommonHeaders() {
            request.addValue(headerValue, forHTTPHeaderField: headerKey)
        }
        
        
        /* Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                let newError = ParseClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            } else {
                let processedData = self.specialProcessing(data!)
                ParseClient.parseJSONWithCompletionHandler(processedData, completionHandler: completionHandler)
            }
        }
        
        /* Start the request */
        task.resume()
        
        return task
    }
    
    // MARK: - GET
    
    func taskForGETMethod(method: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        return taskForMethod("GET", method: method, parameters: parameters, jsonBody: [:], completionHandler: completionHandler)
    }
    
    // MARK: - POST
    
    func taskForPOSTMethod(method: String, parameters: [String : AnyObject], jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        return taskForMethod("POST", method: method, parameters: parameters, jsonBody: jsonBody, completionHandler: completionHandler)
    }
    
    // MARK: - PUT
    
    func taskForPUTMethod(method: String, parameters: [String : AnyObject], jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        return taskForMethod("PUT", method: method, parameters: parameters, jsonBody: jsonBody, completionHandler: completionHandler)
    }
    
    /* Helper function to preprocess data */
    func specialProcessing(data: NSData) -> NSData? {
        return data
    }
    
    /* Helper: Substitute the key for the value that is contained within the method name */
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        do {
            if let data = data, let parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? [String : AnyObject] {
                
                if let errorMessage = parsedResult[APIClient.ErrorKey] as? String {
                    
                    let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                    
                    return NSError(domain: "Udacity Error", code: 1, userInfo: userInfo)
                }
            }
        } catch _ {}
        
        return error
    }
    
    class func createError(domain: String, msg: String) -> NSError {
        return NSError(domain: domain, code: 0, userInfo: [NSLocalizedDescriptionKey: msg])
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        do {
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            let parsedResult: AnyObject? = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
            completionHandler(result: parsedResult, error: nil)
        } catch let parseError as NSError {
            completionHandler(result: nil, error: parseError)
        }
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
}