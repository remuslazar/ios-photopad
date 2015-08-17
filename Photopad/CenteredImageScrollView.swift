//
//  CenteredImageScrollView.swift
//  Photopad
//
//  Created by Remus Lazar on 17.08.15.
//  Copyright (c) 2015 Remus Lazar. All rights reserved.
//

import UIKit

class CenteredImageScrollView: UIScrollView {

    weak var imageView: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if (imageView != nil) {

            // center horizontally
            if imageView.frame.size.width < self.bounds.size.width {
                imageView.frame.origin.x = (self.bounds.size.width - imageView.frame.size.width) / 2
            } else {
                imageView.frame.origin.x = 0
            }

            // center vertically
            if imageView.frame.size.height < self.bounds.size.height {
                imageView.frame.origin.y = (self.bounds.size.height - imageView.frame.size.height) / 2
            } else {
                imageView.frame.origin.y = 0
            }
        }
    }
    
}
