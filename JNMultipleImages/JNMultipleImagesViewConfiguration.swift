//
//  JNMultipleImagesViewConfiguration.swift
//  JNMultipleImages
//
//  Created by Rola Salahat on 23/07/2024.
//  Copyright © 2024 Mohammad Nabulsi. All rights reserved.
//

import Foundation

/// Multiple images view configuration
public class JNMultipleImagesViewConfiguration {
    
    /// Count label position
    public var countLabelPosition: JNMultipleImagesView.JNMultipleImagesCountLabelPosition
    
    /// Place holder image
    public var placeHolderImage: UIImage?
    
    /// Items margin
    public var itemsMargin: CGFloat
    
    /// Style
    public var style: JNMultipleImagesView.style
    
    /// Corner radius
    public var cornerRadius: CGFloat
    
    /// Border color
    public var borderColor: UIColor
    
    /// Border width
    public var borderWidth: CGFloat
    
    /**
     Initializer
     - parameter images: The images array to load which might be string or UIImage
     - parameter countLabelPosition: count label position
     - parameter placeHolderImage: place holder image to use when failed to load image
     - parameter itemsMargin: The margin between images
     - parameter style: displaying image style
     - parameter cornerRadius: corner radius value
     - Parameter borderColor: border color
     - Parameter borderWidth: border width value
     */
    public init(countLabelPosition: JNMultipleImagesView.JNMultipleImagesCountLabelPosition, placeHolderImage: UIImage? = nil, itemsMargin: CGFloat, style: JNMultipleImagesView.style, cornerRadius: CGFloat, borderColor: UIColor, borderWidth: CGFloat) {
        self.countLabelPosition = countLabelPosition
        self.placeHolderImage = placeHolderImage
        self.itemsMargin = itemsMargin
        self.style = style
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }
}
