//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Ezequiel França on 09/30/16.
//  Copyright © 2016 Ezequiel França All rights reserved.
//

import Foundation

extension UdacityClient {
    
    // MARK: - Constants
    struct Constants {
        
        // MARK: URLs
        static let BaseURL : String = "https://www.udacity.com/api/"
        static let SingUpURL : String = "https://www.udacity.com/account/auth#!/signin"
        
    }
    
    // MARK: - Methods
    struct Methods {
        
        // MARK: Session
        static let Session = "session"
        
        // MARK: Users
        static let UserProfile = "users/{id}"
        
    }
    
    // MARK: - JSON Body Keys
    struct JSONBodyKeys {
        
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
        static let FacebookMobile = "facebook_mobile"
        static let AccessToken = "access_token"
        
    }
    
    // MARK: - JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: Login
        static let Account = "account"
        static let Session = "session"
        
        static let AccountRegistered = "registered"
        static let AccountKey = "key"
        static let SessionId = "id"
        
        // MARK: Login Error
        static let Status = "status"
        static let Error = "error"
        
        // MARK: User profile
        static let User = "user"
        static let FirstName = "first_name"
        static let LastName = "last_name"
        
    }
}