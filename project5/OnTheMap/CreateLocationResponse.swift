//
//  CreateLocationResponse.swift
//  OnTheMap
//
//  Created by Ezequiel França on 09/30/16.
//  Copyright © 2016 Ezequiel França All rights reserved.
//

import Foundation

class CreateLocationResponse {
    
    var createdAt : String!
    var objectId : String!
    
    convenience init?(dictionary: [String : AnyObject]) {
        
        self.init()
        
        if let createdAt = dictionary[ParseClient.JSONResponseKeys.CreatedAt] as? String {
            self.createdAt = createdAt
        } else { return nil }
        
        if let objectId = dictionary[ParseClient.JSONResponseKeys.ObjectId] as? String {
            self.objectId = objectId
        } else { return nil }
    }
}