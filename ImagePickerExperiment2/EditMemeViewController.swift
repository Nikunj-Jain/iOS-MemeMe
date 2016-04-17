//
//  ViewController.swift
//  ImagePickerExperiment2
//
//  Created by Nikunj Jain on 26/02/16.
//  Copyright © 2016 Nikunj Jain. All rights reserved.
//

import UIKit

class EditMemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    // Connecting all the outlets
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var shareMemeButton: UIBarButtonItem!
    @IBOutlet weak var discardButton: UIBarButtonItem!
    
    //Flag is used to determine if bottom text field is being edited, 
    //so that view's frame can be moved up
    var flag = false
    var isEditingMeme = false
    var passedMeme: Meme?
    
    //Attributes for the TextFields
    let memeTextAttributes = [
        NSStrokeColorAttributeName: UIColor.blackColor(),
        NSForegroundColorAttributeName: UIColor.whiteColor(),
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName: -3.0
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProperties(topTextField)
        setProperties(bottomTextField)
        
        if isEditingMeme {
            imagePickerView.image = passedMeme?.originalImage
            imagePickerView.contentMode = UIViewContentMode.ScaleAspectFit
            topTextField.text = passedMeme?.topMessage
            bottomTextField.text = passedMeme?.bottomMessage
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        if let _ = imagePickerView.image {
            shareMemeButton.enabled = true
            discardButton.title = "Discard"
            topTextField.enabled = true
            bottomTextField.enabled = true
        } else {
            shareMemeButton.enabled = false
            discardButton.title = "Cancel"
            topTextField.enabled = false
            bottomTextField.enabled = false
        }
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        unsubscribeFromKeyboardNotifications()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    //If Album is chosen
    @IBAction func pickAnImage(sender: AnyObject) {
        presentVC(false)
    }
    
    //If Camera is chosen
    @IBAction func pickAnImageFromCamera(sender: UIBarButtonItem) {
        presentVC(true)
    }
    
    func setProperties(textField: UITextField) {
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .Center
        textField.borderStyle = UITextBorderStyle.None
        textField.backgroundColor = UIColor.clearColor()
    }
    
    func presentVC(isCamera: Bool) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        
        if isCamera {
            pickerController.sourceType = UIImagePickerControllerSourceType.Camera
        } else {
            pickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        
        presentViewController(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePickerView.image = image
        imagePickerView.contentMode = UIViewContentMode.ScaleAspectFit
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Close keyboard when return key is pressed
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    //Clearing the text in texfields if user has not given any new text
    func textFieldDidBeginEditing(textField: UITextField) {
        if let text = textField.text {
            if text == "BOTTOM" || text == "TOP" {
                textField.text = ""
            }
        }
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if bottomTextField.editing {
            flag = true
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if flag {
            view.frame.origin.y = 0
            flag = false
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    func saveMeme() {
        
        let meme = Meme(topMessage: topTextField.text!, bottomMessage: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: generateMemedImage())
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
    }
    
    func generateMemedImage() -> UIImage {
        topToolBar.hidden = true
        bottomToolBar.hidden = true
        
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        topToolBar.hidden = false
        bottomToolBar.hidden = false
        
        return memedImage
    }
    
    //Method that runs when the Action/Share icon is pressed
    @IBAction func shareMeme(sender: UIBarButtonItem) {
        
        let memedImage = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        controller.completionWithItemsHandler = {
            (s: String?, ok: Bool, items: [AnyObject]?, err:NSError?) -> Void in
            if ok {
                self.saveMeme()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        self.presentViewController(controller, animated: true, completion: nil)
    }
    //Method that runs when discard button is pressed
    @IBAction func discardImage(sender: UIBarButtonItem) {
        if discardButton.title == "Discard" {
            imagePickerView.image = nil
            shareMemeButton.enabled = false
            discardButton.title = "Cancel"
            topTextField.text = "TOP"
            bottomTextField.text = "BOTTOM"
        } else if discardButton.title == "Cancel" {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
}