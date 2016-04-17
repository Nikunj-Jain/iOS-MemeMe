//
//  SentMemesTableViewController.swift
//  Meme Me V1.0
//
//  Created by Nikunj Jain on 01/03/16.
//  Copyright © 2016 Nikunj Jain. All rights reserved.
//

import Foundation
import UIKit

class SentMemesTableViewController: UITableViewController {
   
    var allMemes: [Meme]!
    var flag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "newMeme")
        navigationItem.rightBarButtonItem = button
        navigationItem.title = "Sent Memes"
        updateModel()
        if allMemes.count == 0 {
            flag = true
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateModel()
        tableView!.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if flag {
            flag = false
            newMeme()
        }
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allMemes.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let memeDetailVC = storyboard.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        memeDetailVC.meme = allMemes[indexPath.row]
        memeDetailVC.index = indexPath.row
        
        if let localNavigationController = navigationController {
            localNavigationController.pushViewController(memeDetailVC, animated: true)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SentMemesTableViewCell")! as UITableViewCell
        
        let meme = allMemes[indexPath.row]
        cell.textLabel?.text = "\(meme.topMessage)...\(meme.bottomMessage)"
        cell.imageView?.image = meme.memedImage
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            (UIApplication.sharedApplication().delegate as! AppDelegate).memes.removeAtIndex(indexPath.row)
            updateModel()
            self.tableView!.reloadData()
        }
    }
    
    func newMeme() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let editMemeVC = storyboard.instantiateViewControllerWithIdentifier("EditMemeViewController") as! EditMemeViewController
        self.presentViewController(editMemeVC, animated: true, completion: nil)
    }
    
    func updateModel() {
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        allMemes = appDelegate.memes
    }
}