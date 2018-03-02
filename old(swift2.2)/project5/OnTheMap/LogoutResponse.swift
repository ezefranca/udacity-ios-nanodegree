//
//  LogoutResponse.swift
//  OnTheMap
//
//  Created by Ezequiel França on 09/30/16.
//  Copyright © 2016 Ezequiel França All rights reserved.
//

import Foundation

class LogoutResponse {
    
    var sessionId: String?
    
    init() {}
    
    convenience init?(dictionary: [String : AnyObject]) {
        
        self.init()
        
        if let sessionDictionary = dictionary[UdacityClient.JSONResponseKeys.Session] as? [String: AnyObject] {
            
            if let sessionId = sessionDictionary[UdacityClient.JSONResponseKeys.SessionId] as? String {
                self.sessionId = sessionId
            } else { return nil }
            
        } else { return nil }
    }
}