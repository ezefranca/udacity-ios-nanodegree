//
//  MemeCollectionViewController.swift
//  MemeMe
//
//  Created by Ezequiel on 7/19/16.
//  Copyright © 2016 Ezequiel F. Santos. All rights reserved.
//

import UIKit

class MemeCollectionViewController: UICollectionViewController {
    
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    
    @IBAction func addNewMeme(sender: AnyObject) {
        
        // Open a new UIView use View Controller do not passed data.
        if let resultController = storyboard!.instantiateViewControllerWithIdentifier("MemeEditorViewController") as? MemeEditorViewController {
            presentViewController(resultController, animated: true, completion: nil)
        }

        
    }
    var allMeme: [Meme]!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = false
        let applicationDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        
        allMeme = applicationDelegate.memes
        
        collectionView?.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let space:CGFloat = 3.0
        let dimension = (self.view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSizeMake(dimension, dimension)
        
        self.collectionView?.backgroundColor = UIColor.whiteColor()
        
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.allMeme.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCollectionViewCell", forIndexPath: indexPath) as! MemeCollectionViewCell
        
        let meme = self.allMeme[indexPath.row]
        
        cell.memedImageView?.image = meme.memedImage
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        detailController.meme = self.allMeme[indexPath.row]
        self.navigationController!.pushViewController(detailController, animated: true)
    }
    
}
