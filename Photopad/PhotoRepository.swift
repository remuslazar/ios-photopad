//
//  PhotoRepository.swift
//  Photopad
//
//  Created by Remus Lazar on 16.08.15.
//  Copyright (c) 2015 Remus Lazar. All rights reserved.
//

import Foundation

class PhotoRepository {
    
    static let sharedInstance = PhotoRepository()
    
    private struct Constants {
        static let NextImageNumberDefaultsKey = "PhotoRepository.LastFilenameNumber"
        static let FilenamePrefix = "IMG"
        static let CurrentImageFilename = "current-image.jpg"
    }
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    var nextImageFileName: String {
        var lastImageNumber = defaults.objectForKey(Constants.NextImageNumberDefaultsKey) as? Int ?? 0
        lastImageNumber++
        defaults.setInteger(lastImageNumber, forKey: Constants.NextImageNumberDefaultsKey)
        defaults.synchronize()
        return Constants.FilenamePrefix + String(format: "%05d", arguments: [lastImageNumber])
    }
    
    lazy var documentsURL: NSURL = {
        let fileManager = NSFileManager()
        return fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    }()
    
    var currentImageURL: NSURL {
        return documentsURL.URLByAppendingPathComponent(Constants.CurrentImageFilename)
    }
    
    func saveLastImage(imageData: NSData) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            imageData.writeToURL(currentImageURL, atomically: true)
        }
    }
    
    func loadLastImage() -> NSData? {
        return NSData(contentsOfURL: currentImageURL)
    }
    
    func saveImage(imageData: NSData, fileExtension: String = "jpg") {
        let url = documentsURL.URLByAppendingPathComponent(nextImageFileName).URLByAppendingPathExtension(fileExtension)
        imageData.writeToURL(url, atomically: true)
    }
    
}