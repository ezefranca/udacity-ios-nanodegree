//
//  ActivityIndicator.swift
//  OnTheMap
//
//  Created by Ezequiel França on 2/1/16.
//  Copyright © 2016 Ezequiel França All rights reserved.
//

import Foundation
import UIKit

/*
 * Code inspired by: 
 * http://stackoverflow.com/questions/28785715/how-to-display-an-activity-indicator-with-text-on-ios-8-with-swift
 */

class SpecialActivityIndicator {
    
    var modalView: UIView?
    
    func show(view: UIView, msg: String) {
        
        hide()
        
        let strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 200, height: 50))
        let messageFrame = UIView(frame: CGRect(x: view.frame.midX - 90, y: view.frame.midY - 25 , width: 180, height: 50))
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        let backGroundFrame = UIView(frame: view.frame)
        
        strLabel.text = msg
        strLabel.textColor = UIColor.whiteColor()
        
        messageFrame.layer.cornerRadius = 15
        messageFrame.backgroundColor = UIColor(white: 0, alpha: 0.7)
        
        backGroundFrame.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.startAnimating()
        
        messageFrame.addSubview(activityIndicator)
        messageFrame.addSubview(strLabel)
        
        backGroundFrame.addSubview(messageFrame)
        
        modalView = backGroundFrame
        view.addSubview(backGroundFrame)
    }
    
    func hide() {
        if let modalView = modalView {
            modalView.removeFromSuperview()
        }
        
        modalView = nil
    }
    
    class func sharedInstance() -> SpecialActivityIndicator {
        
        struct Singleton {
            static var sharedInstance = SpecialActivityIndicator()
        }
        
        return Singleton.sharedInstance
    }

}