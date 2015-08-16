//
//  PhotoViewController.swift
//  Photopad
//
//  Created by Remus Lazar on 16.08.15.
//  Copyright (c) 2015 Remus Lazar. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - public API
    var image: UIImage? {
        didSet {
            imageView?.image = image
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            if image != nil {
                imageView.image = image
            }
        }
    }
    
    @IBAction func exportImage(sender: UISegmentedControl) {
        if let image = image {
            
        }
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let picker = UIImagePickerController()
            picker.sourceType = .Camera
            picker.allowsEditing = true
            picker.delegate = self
            presentViewController(picker, animated: true, completion: nil)
            
        }
    }

    // MARK: - UIImagePickerController Delegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        if let metadata = info[UIImagePickerControllerMediaMetadata] as? NSDictionary {
            println("metadata: \(metadata)")
        }
        self.image = image
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - View Lifetime Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if image == nil {
            takePhoto(self)
        }
        
        // just a quick workaround for being able to use the simulator
        if image == nil {
            image = UIImage(named: "DummyImage")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
