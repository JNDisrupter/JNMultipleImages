//
//  JNImage.swift
//  JNMultipleImages
//
//  Created by JN Disrupter on 9/13/17.
//  Copyright © 2017 JN Disrupter. All rights reserved.
//

import Foundation
import UIKit

/// JNImage
open class JNImage {
    
    /// Image
    open var image: UIImage?
    
    /// Url
    open var url : String
    
    /**
     Initializer
     */
    public init() {
        
        // Init Image
        self.image = nil
        
        // Init url
        self.url = ""
    }
}
