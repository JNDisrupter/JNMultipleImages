//
//  JNMultipleImagesView.swift
//  JNMultipleImages
//
//  Created by JN Disrupter on 9/13/17.
//  Copyright © 2017 JN Disrupter. All rights reserved.
//

import UIKit
import SDWebImage

/**
 Count Label Position.
 
 ````
 case fullScreen
 case bottomRight
 ````
 */
public enum JNMultipleImagesCountLabelPosition {
    
    /// Show label on the whole view.
    case fullScreen
    
    /// Show label only on the bottom right image.
    case bottomRight
}

/// Multiple images view
open class JNMultipleImagesView: UIView {
    
    /// Images container view
    @IBOutlet private weak var imagesContainerView: UIView!
    
    /// Count label
    @IBOutlet public weak var countLabel: UILabel!
    
    /// Delegate
    public weak var delegate : JNMultipleImagesViewDelegate!
    
    /**
     Loads a view instance from the xib file
     
     - returns: loaded view
     */
    private func loadViewFromXibFile() -> UIView {
        let bundle = Bundle(for: JNMultipleImagesView.self)
        let nib = UINib(nibName: "JNMultipleImagesView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    /**
     Initializer method with CGRect
     - parameters frame : CGRect
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Setup view
        self.setupView()
    }
    
    /**
     Initializer method with NSCoder
     - parameters aDecoder : NSCoder
     */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Setup view
        self.setupView()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        // Get views
        let views = self.imagesContainerView.subviews
        
        // Iterate items
        for view in views {
            
            // Get view as image view and get image
            if let view = view as? UIImageView , let image = view.image{
                
                // Adjust image view content mode according to size
                self.adjustImageViewContentModeAccordingToImage(image: image, mediaView: view)
            }
        }
    }
    
    /**
     Sets up the view by loading it from the xib file and setting its frame
     */
    private func setupView() {
        let view = loadViewFromXibFile()
        view.frame = bounds
        self.addSubview(view)
        
        // Add constarins to view
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        view.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        
        // Setup view
        self.clipsToBounds = true
        
        // Reset view
        self.resetView()
    }
    
    /**
     Reset view: Clear all images and reset count label
     */
    public func resetView() {
        
        // Clear all sub view in media container
        for view in self.imagesContainerView.subviews {
            view.removeFromSuperview()
        }
        
        // Reset Count label
        self.countLabel.isHidden = true
        self.countLabel.text = ""
    }
    
    /**
     Clear images cache
     */
    public func clearImagesCache() {
        
        // Clear memory cache
        SDImageCache.shared().clearMemory()
        
        // Clear disk cache
        SDImageCache.shared().clearDisk()
    }
    
    /**
     Setup multiple images view
     - parameter images: The NJImage array to load
     - parameter countLabelPosition: count label position
     - parameter placeHolderImage: place holder image to use when failed to load image
     - parameter itemsMargin: The margin between images
     */
    public func setup(images : [JNImage] , countLabelPosition : JNMultipleImagesCountLabelPosition = .bottomRight , placeHolderImage : UIImage? = nil , itemsMargin : CGFloat = 2.0) {
        
        // Reset view
        self.resetView()
        
        var imagesPlaceHolder = placeHolderImage
        
        // Set default placeholder image
        if imagesPlaceHolder == nil {
            let bundle = Bundle(for: JNMultipleImagesView.self)
            imagesPlaceHolder = UIImage(named: "BrokenImageDefaultPlaceholder", in: bundle, compatibleWith: nil)
        }
        
        for i in 0..<min(4,images.count) {
            
            let mediaView = UIImageView(image: imagesPlaceHolder)
            
            // Get media item
            let mediaItem = images[i]
            
            // Get image
            if let image = mediaItem.image {
                
                // Set image
                mediaView.image = image
            } else if let url = URL(string: mediaItem.url) , !mediaItem.url.isEmpty {
                
                // Load image
                mediaView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.white)
                mediaView.sd_setShowActivityIndicatorView(true)
                
                // Set image
                mediaView.sd_setImage(with: url, placeholderImage: placeHolderImage, options: [SDWebImageOptions.retryFailed], completed: { (image, error, cashe, url) in
                    
                    if let error = error , let imageUrl = url {
                        
                        // Set place holder image
                        mediaView.image = imagesPlaceHolder
                        
                        // Call delegate
                        if self.delegate != nil && self.delegate.responds(to: #selector(JNMultipleImagesViewDelegate.jsMultipleImagesView(failedToLoadImage:error:))) {
                            self.delegate.jsMultipleImagesView!(failedToLoadImage: imageUrl.absoluteString, error: error)
                        }
                    } else if let image = image , let imageUrl = url {
                        
                        // Set image
                        mediaView.image = image
                        
                        // Call delegate
                        if self.delegate != nil && self.delegate.responds(to: #selector(JNMultipleImagesViewDelegate.jsMultipleImagesView(didLoadImage:image:))) {
                            self.delegate.jsMultipleImagesView!(didLoadImage: imageUrl.absoluteString, image: image)
                        }
                    }
                    
                    // Adjust media view content mode
                    self.adjustImageViewContentModeAccordingToImage(image: mediaView.image!, mediaView: mediaView)
                })
            }
            
            // Clip to bounds
            mediaView.clipsToBounds = true
            
            // Add media view
            self.imagesContainerView.addSubview(mediaView)
        }
        
        // Add count label if number of item more than the limit
        if images.count > 4 {
            
            // Setup count label
            let numberOfExtraMedia = images.count - 4
            self.countLabel.text = "+" + numberOfExtraMedia.description
            self.countLabel.isHidden = false
            
            // Add count label constraint
            self.addCountLabelConstraint(countLabelPosition: countLabelPosition)
        }
        
        // Add constraints
        self.addConstraints(itemsMargin: itemsMargin)
    }
    
    /**
     Adjust image view content mode according uiimage
     - parameter image : The UIImage to scale
     - parameter mediaView : The UIImageView thats will to be adjusted
     */
    private func adjustImageViewContentModeAccordingToImage(image : UIImage , mediaView : UIImageView) {
        
        let heightInPoints = image.size.height
        let heightInPixels = heightInPoints * image.scale
        
        let widthInPoints = image.size.width
        let widthInPixels = widthInPoints * image.scale
        
        let firstCondition = widthInPixels < mediaView.frame.size.width && heightInPixels < mediaView.frame.size.height
        let secondCondtion = (heightInPixels / widthInPixels) < mediaView.frame.size.height / mediaView.frame.size.width
        let thirdCondition = CGFloat(widthInPoints / heightInPixels) < mediaView.frame.size.width / mediaView.frame.size.height
        
        // Set image content mode according image width and height
        if firstCondition || secondCondtion || thirdCondition {
            
            // Set content mode
            mediaView.contentMode = UIViewContentMode.scaleAspectFill
        } else if widthInPoints > heightInPixels && heightInPixels < mediaView.frame.size.height {
            
            // Set content mode
            mediaView.contentMode = UIViewContentMode.topRight
        } else {
            
            // Set content mode
            mediaView.contentMode = UIViewContentMode.scaleAspectFit
        }
        
        // Layout media view
        mediaView.setNeedsDisplay()
    }
    
    /**
     Add constraints
     - parameter itemsMargin : Margin between images
     */
    private func addConstraints(itemsMargin : CGFloat ) {
        
        // Get views
        let views = self.imagesContainerView.subviews
        
        // Iterate items
        for (index, view) in views.enumerated() {
            
            // Set auto translating auto layout
            view.translatesAutoresizingMaskIntoConstraints = false
            
            // Check if one item
            if views.count == 1 {
                
                // Add constraints
                view.leadingAnchor.constraint(equalTo: self.imagesContainerView.leadingAnchor).isActive = true
                view.topAnchor.constraint(equalTo: self.imagesContainerView.topAnchor).isActive = true
                view.bottomAnchor.constraint(equalTo: self.imagesContainerView.bottomAnchor).isActive = true
                view.trailingAnchor.constraint(equalTo: self.imagesContainerView.trailingAnchor).isActive = true
                
            } else if views.count == 2 {
                
                // Add constraints
                view.topAnchor.constraint(equalTo: self.imagesContainerView.topAnchor).isActive = true
                view.bottomAnchor.constraint(equalTo: self.imagesContainerView.bottomAnchor).isActive = true
                
                // Check if first item
                if index == 0 {
                    view.leadingAnchor.constraint(equalTo: self.imagesContainerView.leadingAnchor).isActive = true
                } else if index == 1 {
                    view.trailingAnchor.constraint(equalTo: self.imagesContainerView.trailingAnchor).isActive = true
                }
                
                // Add width constraints
                view.widthAnchor.constraint(equalTo: self.imagesContainerView.widthAnchor, multiplier: 0.5 , constant:-itemsMargin / 2).isActive = true
            } else if views.count == 3 {
                
                // Check if first item
                if index == 0 {
                    
                    // Add constraints
                    view.leadingAnchor.constraint(equalTo: self.imagesContainerView.leadingAnchor).isActive = true
                    view.topAnchor.constraint(equalTo: self.imagesContainerView.topAnchor).isActive = true
                    view.trailingAnchor.constraint(equalTo: self.imagesContainerView.trailingAnchor).isActive = true
                    
                    // Add height constraints
                    view.heightAnchor.constraint(equalTo: self.imagesContainerView.widthAnchor, multiplier: 2/3, constant: -itemsMargin / 2).isActive = true
                } else if index == 1 {
                    
                    // Add constraints
                    view.bottomAnchor.constraint(equalTo: self.imagesContainerView.bottomAnchor).isActive = true
                    view.leadingAnchor.constraint(equalTo: self.imagesContainerView.leadingAnchor).isActive = true
                    
                    // Get first view
                    let firstView = views[0]
                    
                    // Add leading constraint
                    view.topAnchor.constraint(equalTo: firstView.bottomAnchor, constant: itemsMargin).isActive = true
                    
                    // Add width constraints
                    view.widthAnchor.constraint(equalTo: self.imagesContainerView.widthAnchor, multiplier: 0.5 , constant:-itemsMargin / 2).isActive = true
                } else if index == 2 {
                    
                    // Add constraints
                    view.bottomAnchor.constraint(equalTo: self.imagesContainerView.bottomAnchor).isActive = true
                    view.trailingAnchor.constraint(equalTo: self.imagesContainerView.trailingAnchor).isActive = true
                    
                    // Get first view
                    let firstView = views[0]
                    
                    // Add leading constraint
                    view.topAnchor.constraint(equalTo: firstView.bottomAnchor, constant: itemsMargin).isActive = true
                    
                    // Add width constraints
                    view.widthAnchor.constraint(equalTo: self.imagesContainerView.widthAnchor, multiplier: 0.5 , constant:-itemsMargin / 2).isActive = true
                }
            } else if views.count == 4 {
                
                // Check if first item
                if index == 0 {
                    
                    // Add constraints
                    view.leadingAnchor.constraint(equalTo: self.imagesContainerView.leadingAnchor).isActive = true
                    view.topAnchor.constraint(equalTo: self.imagesContainerView.topAnchor).isActive = true
                    view.trailingAnchor.constraint(equalTo: self.imagesContainerView.trailingAnchor).isActive = true
                    
                    // Add height constraints
                    view.heightAnchor.constraint(equalTo: self.imagesContainerView.widthAnchor, multiplier: 2/3, constant: -itemsMargin / 2).isActive = true
                } else {
                    
                    // Add constraints
                    view.bottomAnchor.constraint(equalTo: self.imagesContainerView.bottomAnchor).isActive = true
                    
                    // Get first view
                    let firstView = views[0]
                    
                    // Add leading constraint
                    view.topAnchor.constraint(equalTo: firstView.bottomAnchor, constant: itemsMargin).isActive = true
                    
                    // Add width constraints
                    view.widthAnchor.constraint(equalTo: self.imagesContainerView.widthAnchor, multiplier: 1/3 , constant:-itemsMargin / 2).isActive = true
                    
                    if index == 1 {
                        
                        // Add constraints
                        view.leadingAnchor.constraint(equalTo: self.imagesContainerView.leadingAnchor).isActive = true
                    } else {
                        
                        // Get first view
                        let previousView = views[index - 1]
                        
                        // Add top constraint
                        view.leftAnchor.constraint(equalTo: previousView.rightAnchor, constant: itemsMargin).isActive = true
                    }
                }
            }
        }
    }
    
    /**
     Add count label constraint
     - parameter countLabelPosition : Count label position
     */
    private func addCountLabelConstraint(countLabelPosition : JNMultipleImagesCountLabelPosition) {
        
        // Get views
        let views = self.imagesContainerView.subviews
        
        // Check if there is 4 view
        if views.count == 4 {
            
            // Set translate auto sizing mask
            self.countLabel.translatesAutoresizingMaskIntoConstraints = false
            
            var targetView = self.imagesContainerView!
            
            // Check count label position
            if countLabelPosition == JNMultipleImagesCountLabelPosition.bottomRight {
                
                // Set target view
                targetView = views[3]
            }
            
            // Add constraints
            self.countLabel.leadingAnchor.constraint(equalTo: targetView.leadingAnchor).isActive = true
            self.countLabel.topAnchor.constraint(equalTo: targetView.topAnchor).isActive = true
            self.countLabel.bottomAnchor.constraint(equalTo: targetView.bottomAnchor).isActive = true
            self.countLabel.trailingAnchor.constraint(equalTo: targetView.trailingAnchor).isActive = true
        }
    }
}

/// JNMultiple Images View Delegate
@objc public protocol JNMultipleImagesViewDelegate : NSObjectProtocol {
    
    /**
     Did load image
     - parameter imageUrl: The image url for the loaded image
     - parameter image: The uiimage object that have been loaded
     */
    @objc optional func jsMultipleImagesView(didLoadImage imageUrl : String , image : UIImage)
    
    /**
     Failed to load image
     - parameter imageUrl: The image url
     - parameter error: The error
     */
    @objc optional func jsMultipleImagesView(failedToLoadImage imageUrl : String , error : Error)
}
