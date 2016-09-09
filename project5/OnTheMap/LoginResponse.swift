//
//  LoginResponse.swift
//  OnTheMap
//
//  Created by Ezequiel França on 09/30/16.
//  Copyright © 2016 Ezequiel França All rights reserved.
//

import Foundation


class LoginResponse {
    
    var accountId: String?
    var sessionId: String?
    
    init() {}
    
    convenience init?(dictionary: [String : AnyObject]) {
        
        self.init()
        
        if let accountDictionary = dictionary[UdacityClient.JSONResponseKeys.Account] as? [String : AnyObject] {
            
            if let accountId = accountDictionary[UdacityClient.JSONResponseKeys.AccountKey] as? String {
                self.accountId = accountId
            } else {return nil}
            
            
            if let accountRegistered = accountDictionary[UdacityClient.JSONResponseKeys.AccountRegistered] as? Bool {
                if !accountRegistered {
                    return nil
                }
            } else {return nil}

        } else { return nil }
        
        if let sessionDictionary = dictionary[UdacityClient.JSONResponseKeys.Session] as? [String: AnyObject] {
            
            if let sessionId = sessionDictionary[UdacityClient.JSONResponseKeys.SessionId] as? String {
                self.sessionId = sessionId
            } else { return nil }
            
        } else { return nil }
    }
}