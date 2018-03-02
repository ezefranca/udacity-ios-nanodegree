//
//  Photo.swift
//  VirtualTourist
//
//  Created by Ezequiel França on 09/07/16.
//  Copyright © 2016 Ezequiel. All rights reserved.
//

import Foundation
import CoreData
import UIKit

// Class responsible to represent a PHOTO in the core data model

class Photo: NSManagedObject {
    
    @NSManaged var id: String?
    @NSManaged var url: String?
    @NSManaged var pin: Pin?
    @NSManaged var photo: NSData?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        id =  (dictionary["id"] as! String)
        
        if let _url = dictionary["url_c"] {
            url = _url as? String
        }
    }
}