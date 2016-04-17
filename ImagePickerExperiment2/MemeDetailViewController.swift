//
//  MemeDetailViewController.swift
//  Meme Me V1.0
//
//  Created by Nikunj Jain on 01/03/16.
//  Copyright © 2016 Nikunj Jain. All rights reserved.
//

import Foundation
import UIKit

class MemeDetailViewController: UIViewController {
    
    var meme: Meme!
    var index: Int!
    
    @IBOutlet weak var memedImage: UIImageView!
    
    override func viewWillAppear(animated: Bool) {
        memedImage.image = meme.memedImage
    }
    
    override func viewDidLoad() {
        automaticallyAdjustsScrollViewInsets = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem (title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: "editMeme")
        navigationItem.title = "Meme Me V2.0"
    }
    
    func editMeme() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let editMemeVC = storyboard.instantiateViewControllerWithIdentifier("EditMemeViewController") as! EditMemeViewController
        editMemeVC.isEditingMeme = true
        editMemeVC.passedMeme = meme
        presentViewController(editMemeVC, animated: true, completion: nil)
    }
}