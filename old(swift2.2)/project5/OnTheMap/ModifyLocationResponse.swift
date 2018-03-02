//
//  ModifyLocationResponse.swift
//  OnTheMap
//
//  Created by Ezequiel França on 09/30/16.
//  Copyright © 2016 Ezequiel França All rights reserved.
//

import Foundation

class ModifyLocationResponse {
    
    var updatedAt : String!
    
    convenience init?(dictionary: [String : AnyObject]) {
        
        self.init()
        
        if let updatedAt = dictionary[ParseClient.JSONResponseKeys.UpdatedAt] as? String {
            self.updatedAt = updatedAt
        } else { return nil }
    }
}