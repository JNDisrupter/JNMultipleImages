//
//  JNImage.swift
//  JNMultipleImages
//
//  Created by JN Disrupter on 9/13/17.
//  Copyright © 2017 JN Disrupter. All rights reserved.
//

import Foundation
import UIKit

open class JNImage {
    
    // Image
    open var image: UIImage?
    
    // Height
    open var height: Int
    
    // Width
    open var width: Int
    
    // Url
    open var url : String
    
    /**
     * Init
     **/
    public init(){
        
        // Set Width
        self.width = 0
        
        // Set Height
        self.height = 0
        
        // Init Image
        self.image = nil
        
        // Init url
        self.url = ""
    }
}
