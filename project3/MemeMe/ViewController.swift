//
//  ViewController.swift
//  MemeMe
//
//  Created by Ezequiel França on 7/31/16.
//  Copyright © 2016 Ezequiel França. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //TOP Toolbar Outlets
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var topToolBarAction: UIBarButtonItem!
    @IBOutlet weak var topToolBarCancel: UIBarButtonItem!
    
    //Bottom Toolbar Outlets
    @IBOutlet weak var bottomToolBar: UIToolbar!
    
    //IMAGE View Outlet
    @IBOutlet weak var imageView: UIImageView!
    
    //TEXT Field Outlets
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    //BOTTOM Toolbar Outlets
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    //DELEGATES
    let memeMeTFDelegate = MemeMeTextFieldDelegate()
    
    //TEXT Field Attribute Settings
    let memeTextAttributes = [
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 30)!,
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSStrokeWidthAttributeName : NSNumber.init(float: -2.0)
    ]
    
    //View Lifecycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //Enable camera button only if the device has a camera
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        //Enable Keyboard
        subscribeToKeyboardNotifications()
        
        //configure topTextField
        configureTextField(topTextField)
        
        //configure bottomTextField
        configureTextField(bottomTextField)
        
        topTextField.delegate = memeMeTFDelegate
        bottomTextField.delegate = memeMeTFDelegate
        
        //prefill Default Text Values into Text Fields
        prefillTextFieldsWithDefault()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        
    }
    @IBAction func topBarCancelPressed(sender: AnyObject) {
        //reset Text Fields and top Bar
        textFieldsToBeHidden(true)
        
        prefillTextFieldsWithDefault()
        
        topToolBar.hidden = true
        
        imageView.image = nil
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func pickImageFromAlbum(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
        pickImageFromSourceType(UIImagePickerControllerSourceType.PhotoLibrary)
    }
    
    @IBAction func pickImageFromCamera(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        presentViewController(imagePicker, animated: true, completion: nil)
        pickImageFromSourceType(UIImagePickerControllerSourceType.Camera)
    }
    
    func pickImageFromSourceType(source: UIImagePickerControllerSourceType){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = source
        presentViewController(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            imageView.image = image
            textFieldsToBeHidden(false)
            topToolBar.hidden = false
        } else{
            textFieldsToBeHidden(true)
            topToolBar.hidden = true
        }
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func shareActivityView(sender: AnyObject) {
        
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image! , memeImage: generateMemedImage())
        let shareItems = [meme.memeImage]
        
        let activityController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil )
        
        
        presentViewController(activityController, animated: true, completion: nil )
        
        //using completion with Items Handler to save image only if action is not cancelled
        activityController.completionWithItemsHandler = {(activityType, completed:Bool, returnedItems:[AnyObject]?, error: NSError?) in
            
            if (!completed){
                return
            }
            UIImageWriteToSavedPhotosAlbum(meme.memeImage, nil, nil, nil)
        }
    }
    
    func generateMemedImage() -> UIImage
    {
        //hide unnecessary toolbars
        toolbarsToBeHidden(true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(imageView.frame, afterScreenUpdates: true)
        let memedImage : UIImage =
            UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //unhide unnecessary toolbars
        toolbarsToBeHidden(false)
        
        return memedImage
    }
    
    //Move keyboard to see edited Text in BottomTextfield
    func subscribeToKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:))    , name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification){
        //Keyboard must shift view ONLY if bottom Text field is editing
        if bottomTextField.editing {
            view.frame.origin.y = getKeyboardHeight(notification) * -1
            NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillShowNotification, object: nil)
        }
    }
    
    func keyboardWillHide(notification: NSNotification){
        //Shift entire view back to bottom after Keyboard hide
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat{
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    func configureTextField(textField: UITextField){
        textField.defaultTextAttributes = memeTextAttributes
        textField.autocapitalizationType = UITextAutocapitalizationType.AllCharacters
        textField.adjustsFontSizeToFitWidth = true
        textField.textAlignment = NSTextAlignment.Center
    }
    
    
    func prefillTextFieldsWithDefault(){
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
    }
    
    func toolbarsToBeHidden(visible: Bool){
        topToolBar.hidden = visible
        bottomToolBar.hidden = visible
    }
    
    func textFieldsToBeHidden(visible: Bool){
        topTextField.hidden = visible
        bottomTextField.hidden = visible
    }
    
    // status bar should be hidden
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
}

