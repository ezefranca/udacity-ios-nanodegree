//
//  StudentLocationsResponse.swift
//  OnTheMap
//
//  Created by Ezequiel França on 09/30/16.
//  Copyright © 2016 Ezequiel França All rights reserved.
//

import Foundation

struct StudentLocationResponse {
    
    var uniqueKey : String!
    var firstName : String!
    var lastName : String!
    var mapString : String!
    var mediaUrl : String!
    var latitude : Float!
    var longitude : Float!
    var objectId : String!
    
    static func parseResponseList(dictionaryList: [[String: AnyObject]]) -> [StudentLocationResponse] {
        
        var studentLocationsList: [StudentLocationResponse] = []
        
        for dictionary in dictionaryList {
            if let studentLocation = StudentLocationResponse(dictionary: dictionary) {
                studentLocationsList.append(studentLocation)
            }
        }
        
        return studentLocationsList
    }
    
    init?(dictionary: [String : AnyObject]) {
        
        if let uniqueKey = dictionary[ParseClient.JSONResponseKeys.UniqueKey] as? String {
            self.uniqueKey = uniqueKey
        } else { return nil }
        
        if let firstName = dictionary[ParseClient.JSONResponseKeys.FirstName] as? String {
            self.firstName = firstName
        } else { return nil }
        
        if let lastName = dictionary[ParseClient.JSONResponseKeys.LastName] as? String {
            self.lastName = lastName
        } else { return nil }
        
        if let mapString = dictionary[ParseClient.JSONResponseKeys.MapString] as? String {
            self.mapString = mapString
        } else { return nil }
        
        if let mediaUrl = dictionary[ParseClient.JSONResponseKeys.MediaUrl] as? String {
            self.mediaUrl = mediaUrl
        } else { return nil }
        
        if let latitude = dictionary[ParseClient.JSONResponseKeys.Latitude] as? Float {
            self.latitude = latitude
        } else { return nil }
        
        if let longitude = dictionary[ParseClient.JSONResponseKeys.Longitude] as? Float {
            self.longitude = longitude
        } else { return nil }
        
        if let objectId = dictionary[ParseClient.JSONResponseKeys.ObjectId] as? String {
            self.objectId = objectId
        } else { return nil }
    }
    
    func getFullName() -> String {
        return (firstName + " " + lastName)
    }
}