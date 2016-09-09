//
//  MemeTableViewController.swift
//  MemeMe
//
//  Created by Ezequiel on 7/19/16.
//  Copyright © 2016 Ezequiel F. Santos. All rights reserved.
//

import UIKit

class MemeTableViewController: UITableViewController {
    
    // MARK: Table View Data Source
    
    //let allMeme = (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    var allMeme:[Meme]!
    
    
    //MARK: - Action
    
    @IBAction func addNewMeme(sender: AnyObject){
        
        // Open a new UIView use View Controller do not passed data.
        if let resultController = storyboard!.instantiateViewControllerWithIdentifier("MemeEditorViewController") as? MemeEditorViewController {
            presentViewController(resultController, animated: true, completion: nil)
        }
        
    }
    //TODO: Edit Action
    @IBAction func toggleEdittingMode(sender:AnyObject){
        
    }
    
    
    
    // MARK: - Lifecycle

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let applicationDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        
        allMeme = applicationDelegate.memes
        
        // reload table view
        tableView.reloadData()
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.allMeme.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MemeCell")!
        
        let meme = self.allMeme[indexPath.row]
        
        //Set the text and image
        cell.imageView?.image = meme.memedImage
        cell.textLabel?.text = "\(meme.topText)...\(meme.bottomText)"
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        detailController.meme = self.allMeme[indexPath.row]
        self.navigationController!.pushViewController(detailController, animated: true)
    }
}
