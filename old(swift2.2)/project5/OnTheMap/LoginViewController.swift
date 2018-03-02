//
//  ViewController.swift
//  OnTheMap
//
//  Created by Ezequiel França on 09/30/16.
//  Copyright © 2016 Ezequiel França All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var facebookButton: FBSDKLoginButton!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        facebookButton.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // Check if user is already logged in
        if let accessToken = FBSDKAccessToken.currentAccessToken() {
            loginWithFacebook(accessToken.tokenString)
        }
        
        addKeyboardGestureRecognizer()
    }
    
    func completeLogin() {
        emailTextField.userInteractionEnabled = true
        passwordTextField.text = ""
            
        performSegueWithIdentifier("loginSegue", sender: self)
    }
    
    func blockLoginButtons(block: Bool) {
        self.facebookButton.enabled = !block
        self.facebookButton.userInteractionEnabled = !block
            
        self.loginButton.enabled = !block
        self.loginButton.userInteractionEnabled = !block
    }

    // MARK: Actions
    @IBAction func loginAction(sender: UIButton) {
        
        let email = emailTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let password = passwordTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if email.isEmpty {
            showGeneralAlert("Error", message: "Missing email field, please fill it", buttonTitle: "Ok")
            return
        }
        
        if password.isEmpty {
            showGeneralAlert("Error", message: "Missing password field, please fill it", buttonTitle: "Ok")
            return
        }
        
        blockLoginButtons(true)
        SpecialActivityIndicator.sharedInstance().show(view, msg: "Loggin in")
        UdacityClient.sharedInstance().postToCreateSession(emailTextField.text!, password: passwordTextField.text!)
        { (success, error) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                self.blockLoginButtons(false)
                SpecialActivityIndicator.sharedInstance().hide()
                
                if success {
                    self.completeLogin()
                } else {
                    self.showGeneralAlert("Error", message: error!.localizedDescription, buttonTitle: "Ok")
                }
            }
        }
    }
    
    @IBAction func singUpAction(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: UdacityClient.Constants.SingUpURL)!)
    }
    
}


extension LoginViewController: FBSDKLoginButtonDelegate {
    
    func loginWithFacebook(accessToken: String) {
        blockLoginButtons(true)
        SpecialActivityIndicator.sharedInstance().show(view, msg: "Loggin in")
        UdacityClient.sharedInstance().postToCreateFacebookSession(accessToken) { (success, error) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                self.blockLoginButtons(false)
                SpecialActivityIndicator.sharedInstance().hide()
                
                if success {
                    self.completeLogin()
                } else {
                    self.showGeneralAlert("Error", message: "Error logging in with Facebook. Try again", buttonTitle: "Ok")
                }
            }
        }
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if !result.isCancelled {
            loginWithFacebook(result.token.tokenString)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) { }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        let canLoginWithFacebook = emailTextField.text!.isEmpty && passwordTextField.text!.isEmpty
        
        if !canLoginWithFacebook {
            showGeneralAlert("", message: "You can login with only one method at the time, please clean the email and password fields", buttonTitle: "Ok")
        }
        
        return canLoginWithFacebook
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide keyboard
        if emailTextField.isFirstResponder() {
            passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
}