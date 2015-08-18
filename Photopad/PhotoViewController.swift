//
//  PhotoViewController.swift
//  Photopad
//
//  Created by Remus Lazar on 16.08.15.
//  Copyright (c) 2015 Remus Lazar. All rights reserved.
//

import UIKit
import AVFoundation

class PhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate {

    // MARK: - public API
    var image: UIImage? {
        didSet {
            convertedImage = image
            centerImage()
            if imageSizeControl.selectedSegmentIndex != 0 {
                imageSizeControl.selectedSegmentIndex = 0
            }
        }
    }
    
    private var convertedImage: UIImage? {
        get { return imageView.image }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            imageView.frame.origin = CGPointZero
            scrollView.contentSize = imageView.frame.size
//            println("imageView frame: \(imageView.frame)")
            fitImage()
            title = ""
            if let imageData = UIImageJPEGRepresentation(imageView.image, 0.75) {
                let fileSizeString = NSByteCountFormatter.stringFromByteCount(Int64(imageData.length), countStyle: NSByteCountFormatterCountStyle.Binary)
                title = "\(fileSizeString) \(Int(imageView.image!.size.width))x\(Int(imageView.image!.size.height))"
            }
            scrollView.backgroundColor = newValue != nil ? .blackColor() : .clearColor()
        }
    }
    
    private func centerImage() {
        let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0)
        let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0)
        imageView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX,
            y: scrollView.contentSize.height * 0.5 + offsetY)
    }

    func scrollViewDidZoom(scrollView: UIScrollView) {
        centerImage()
    }
    
    private func fitImage() {
        if let image = convertedImage {
            let rect = AVMakeRectWithAspectRatioInsideRect(image.size, scrollView.bounds)
            let scale = rect.size.width / image.size.width
            scrollView.minimumZoomScale = scale
            scrollView.maximumZoomScale = max(1.0, scale)
            scrollView.zoomScale = scale
        }
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBAction func selectAction(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "Source Image", message: "Select Input Image Source", preferredStyle: .ActionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .Default, handler: { (_) in self.takePhoto(self) }))
        }
        
        actionSheet.addAction(UIAlertAction(title: "Camera Roll", style: .Default, handler: { (_) in self.pickPhoto() }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(actionSheet, animated: true, completion: nil)

    }
    
    @IBAction func saveImage(sender: AnyObject) {
        if let image = convertedImage {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            saveButton.enabled = false
        }
    }
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    private func pickPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            let picker = UIImagePickerController()
            picker.sourceType = .PhotoLibrary
            picker.delegate = self
            presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    private var imageView = UIImageView()
    
    private func resizeImage(maxSize: CGSize) {
        if let originalImage = image {
            convertedImage = nil
            spinner.startAnimating()
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                let rect = AVMakeRectWithAspectRatioInsideRect(originalImage.size, CGRect(origin: CGPointZero, size: maxSize))
                let scale = rect.size.width / originalImage.size.width
                let image = CIImage(image: originalImage)
                let filter = CIFilter(name: "CILanczosScaleTransform")
                filter.setValue(image, forKey: "inputImage")
                filter.setValue(scale, forKey: "inputScale")
                filter.setValue(1.0, forKey: "inputAspectRatio")
                if let outputImage = filter.valueForKey("outputImage") as? CIImage {
                    let context = CIContext(options: nil)
                    let scaledImage = UIImage(
                        CGImage: context.createCGImage(outputImage, fromRect: outputImage.extent()),
                        scale: 1.0,
                        orientation: originalImage.imageOrientation
                    )
                    dispatch_async(dispatch_get_main_queue()) {
                        self.spinner.stopAnimating()
                        self.convertedImage = scaledImage
                    }
                }
            }
        }
    }
    
    
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.contentSize = imageView.frame.size
            scrollView.delegate = self
            scrollView.minimumZoomScale = 0.03
            scrollView.maximumZoomScale = 1.0
        }
    }
    
    @IBOutlet weak var imageSizeControl: UISegmentedControl!
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    @IBAction func exportImage(sender: UISegmentedControl) {
        saveButton.enabled = true
        switch sender.selectedSegmentIndex {
        case 1: resizeImage(CGSize(width: 1280, height: 1280))
        case 2: resizeImage(CGSize(width: 800, height: 800))
        case 3: resizeImage(CGSize(width: 480, height: 480))
        default: convertedImage = image
        }
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let picker = UIImagePickerController()
            picker.sourceType = .Camera
            picker.allowsEditing = false
            picker.delegate = self
            presentViewController(picker, animated: true, completion: nil)
        }
    }

    // MARK: - UIImagePickerController Delegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.image = originalImage
            PhotoRepository.sharedInstance.saveLastImage(UIImageJPEGRepresentation(originalImage, 1.0))
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - View Lifetime Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        // throw away resources we can recreate later
        convertedImage = nil
        image = nil
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if image == nil {
            spinner.startAnimating()
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)) {
                if let imageData = PhotoRepository.sharedInstance.loadLastImage() {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.spinner.stopAnimating()
                        self.image = UIImage(data: imageData)
                    }
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        fitImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        image = nil
        convertedImage = nil
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
