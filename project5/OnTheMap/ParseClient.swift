//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Ezequiel França on 09/30/16.
//  Copyright © 2016 Ezequiel França All rights reserved.
//

import Foundation

class ParseClient : APIClient {
    
    override func getCommonHeaders() -> [String : String] {
        return [
            "Accept" : "application/json",
            "Content-Type" : "application/json",
            "X-Parse-Application-Id" : Constants.AppId,
            "X-Parse-REST-API-Key" : Constants.ApiKey
        ]
    }
    
    override func getBaseUrl() -> String {
        return Constants.BaseURL
    }
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> ParseClient {
        
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        
        return Singleton.sharedInstance
    }
}