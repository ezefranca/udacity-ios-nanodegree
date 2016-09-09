//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Ezequiel França on 09/30/16.
//  Copyright © 2016 Ezequiel França All rights reserved.
//

import Foundation

class UdacityClient : APIClient {
    
    override func getCommonHeaders() -> [String : String] {
        return [
            "Accept" : "application/json",
            "Content-Type" : "application/json"
        ]
    }
    
    override func getBaseUrl() -> String {
        return Constants.BaseURL
    }
    
    override func specialProcessing(data: NSData) -> NSData? {
        return data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
    }

    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> UdacityClient {
        
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }
}