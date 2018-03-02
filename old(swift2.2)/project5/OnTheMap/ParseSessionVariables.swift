//
//  ParseClientSessionVariables.swift
//  OnTheMap
//
//  Created by Ezequiel França on 2/1/16.
//  Copyright © 2016 Ezequiel França All rights reserved.
//

import Foundation

class ParseSessionVariables : NSObject {
    var studentLocations : [StudentLocationResponse] = []
    var studentLocationId : String?
    
    class func sharedInstance() -> ParseSessionVariables {
        
        struct Singleton {
            static var sharedInstance = ParseSessionVariables()
        }
        
        return Singleton.sharedInstance
    }
}