//
//  ErrorLoginResponse.swift
//  OnTheMap
//
//  Created by Ezequiel França on 2/1/16.
//  Copyright © 2016 Ezequiel França All rights reserved.
//

import Foundation

class ErrorLoginResponse {
    
    var errorCode: Int?
    var errorMsg: String?
    
    init() {}
    
    convenience init?(dictionary: [String : AnyObject]) {
        
        self.init()
        
        if let errorCode = dictionary[UdacityClient.JSONResponseKeys.Status] as? Int {
            self.errorCode = errorCode
        } else { return nil }
            
        if let errorMsg = dictionary[UdacityClient.JSONResponseKeys.Error] as? String {
            self.errorMsg = errorMsg
        } else { return nil }
        
    }
}