//
//  ViewController.swift
//  MemeMe
//
//  Created by Ezequiel on 7/7/16.
//  Copyright © 2016 Ezequiel F. Santos. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate
{
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -5.0
    ]
    
    // MARK: - Action
    
    @IBAction func cancelWindow(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    @IBAction func shareImage(sender: AnyObject) {
        
        //generate a memed image
        
        let memeImage = generateMemedImage()
        
        //define an instance of the ActivityViewController
        //pass the ActivityController a memedImage as an activity item
        
        let controller = UIActivityViewController(activityItems:[memeImage], applicationActivities: nil)
        
        //present the ActivityViewController
        
        self.presentViewController(controller, animated: true, completion: nil)
        
        //save
        
        controller.completionWithItemsHandler = {
            (activity,success,items,error) in self.save()
        }
        
        
        
    }
    
    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        
        pickAnImage("Album")
        
    }
    
    @IBAction func pickAnImageFromCamera(sender: AnyObject) {
        
        pickAnImage("Camera")
    }
    
    
    
    
    // Clear text field
    func textFieldDidBeginEditing(textField: UITextField) {
        
        if textField.text == "TOP" || textField.text == "BOTTOM"{
            textField.text = "";
        }
    }
    
    // dismiss keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    // MARK: - Keyboard
    //Move the view when the keyboard covers the text field
    func subscribeToKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().removeObserver(self,name: UIKeyboardWillShowNotification,object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification){
        if bottomTextField.isFirstResponder(){
            //Check if text field is top Text Field, no need to change position
            //view.frame.origin.y -= getKeyboardHeight(notification)
            
            view.frame.origin.y = getKeyboardHeight(notification) * -1 //better
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification){
        
        self.view.frame.origin.y = 0
        
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTextField(topTextField, defaultText: "TOP")
        setUpTextField(bottomTextField, defaultText: "BOTTOM")
        
        // Init share button and cancel button
        shareButton.enabled = false
        cancelButton.enabled = false
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Control Keyboard view
        subscribeToKeyboardNotifications()
        // Disable camera when the Device without camera
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications()
    }
    
    
    //Hidden Status Bar
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        imagePickerView.image = image
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    // MARK: - function
    
    func pickAnImage(buttonType: String){
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        
        if buttonType == "Camera"{
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        }
        else{
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        presentViewController(imagePicker, animated: true, completion: nil)
        
        self.shareButton.enabled = true
        self.cancelButton.enabled = true
        
    }
    
    // Setup textField attributes
    func setUpTextField(textField: UITextField, defaultText: String){
        
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .Center
        textField.text = defaultText
        
    }
    
    // Create a UIImage that combines the Image View and Labels
    func generateMemedImage() -> UIImage{
        
        // Hide toolbar and navbar
        
        topToolBar.hidden = true
        bottomToolBar.hidden = true
        
        // Render view to an image
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar
        topToolBar.hidden = false
        bottomToolBar.hidden = false
        
        return memedImage
    }
    
    func save(){
        // Update the meme
        let meme = Meme(topText:topTextField.text!,bottomText:bottomTextField.text!,originalImage: imagePickerView.image!, memedImage: generateMemedImage())
        
        // Add it to the memes array on the Application Delegate
        (UIApplication.sharedApplication().delegate as! AppDelegate).memes.append(meme)
        
        var tempMeme: [Meme]! = (UIApplication.sharedApplication().delegate as! AppDelegate).memes
        
        // Dissmiss window / viewcontroller
        self.dismissViewControllerAnimated(true, completion: nil)
        //self.navigationController?.popViewControllerAnimated(true);
        
        
    }
    
}

