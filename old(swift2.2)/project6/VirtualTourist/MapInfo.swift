//
//  MapInfo.swift
//  VirtualTourist
//
//  Created by Ezequiel França on 09/07/16.
//  Copyright © 2016 Ezequiel. All rights reserved.
//

import Foundation
import CoreData

// Class responsible to represent the current location of the user, in the map, in the core data model
class MapInfo: NSManagedObject {
    
    struct Keys {
        static let Longitude = "longitude"
        static let Latitude = "latitude"
        static let LatitudeDelta = "latitudeDelta"
        static let LongitudeDelta = "longitudeDelta"
    }
    
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var latitudeDelta: Double
    @NSManaged var longitudeDelta: Double
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("MapInfo", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        setValues(dictionary)
    }
    
    func setValues(dictionary: [String : AnyObject]) {
        self.latitude = dictionary[Keys.Latitude] as! Double
        self.longitude = dictionary[Keys.Longitude] as! Double
        self.latitudeDelta = dictionary[Keys.LatitudeDelta] as! Double
        self.longitudeDelta = dictionary[Keys.LongitudeDelta] as! Double
    }
}
