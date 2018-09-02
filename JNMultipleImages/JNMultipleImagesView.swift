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
    
    /// Images content mode
    public var imagesContentMode: UIViewContentMode?
    
    /// Delegate
    public weak var delegate : JNMultipleImagesViewDelegate?
    
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
            if let view = view as? UIImageView , let image = view.image {
                
                // Adjust image view content mode according to size
                self.adjustImageViewContentModeAccordingToImage(image: image, mediaView: view)
            }
        }
    }
    
    /**
     Sets up the view by loading it from the xib file and setting its frame
     */
    private func setupView() {
        let view = self.loadViewFromXibFile()
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
        
        // Enable user interactions
        self.isUserInteractionEnabled = true
        self.imagesContainerView.isUserInteractionEnabled = true
        
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
     Did click media view
     */
    @objc private func didClickMediaView(gestureRecognizer : UIGestureRecognizer) {
        
        // Get superclass as image view
        if let mediaView = gestureRecognizer.view as? UIImageView {
            
            // Call delegate
            delegate?.jsMultipleImagesView?(didClickItem: mediaView.tag)
        }
    }
    
    /**
     Get media view at index
     - Parameter index: Media view index
     - Returns: Imageview at index.
     */
    public func getMediaView(at index: Int) -> UIImageView? {
        if self.imagesContainerView.subviews.count > index {
            return self.imagesContainerView.subviews[index] as? UIImageView
        }
        
        return nil
    }
    
    /**
     Setup multiple images view
     - parameter images: The images array to load which might be string or UIImage
     - parameter countLabelPosition: count label position
     - parameter placeHolderImage: place holder image to use when failed to load image
     - parameter itemsMargin: The margin between images
     */
    public func setup(images : [Any] , countLabelPosition : JNMultipleImagesCountLabelPosition = JNMultipleImagesCountLabelPosition.bottomRight , placeHolderImage : UIImage? = nil , itemsMargin : CGFloat = 2.0) {
        
        // Reset view
        self.resetView()
        
        var count = 0
        
        for mediaItem in images {
            
            // Create JNImage instance
            if mediaItem is UIImage || mediaItem is String {
             
                let jnImage = JNImage()
                
                if let mediaItem = mediaItem as? UIImage {
                    jnImage.image = mediaItem
                } else if let mediaItem = mediaItem as? String {
                    jnImage.url = mediaItem
                }
                
                // Create media view
                let mediaView = self.createMediaView(mediaItem: jnImage,placeHolderImage: placeHolderImage)
                
                // Set media view tag
                mediaView.tag = count
                
                // Add media view
                self.imagesContainerView.addSubview(mediaView)
                
                // Increment count
                count += 1
            }
            
            // Check if 4 items created break loop
            if self.imagesContainerView.subviews.count == 4 {
                break
            }
        }
        
        // Setup count label
        self.setupCountLabel(totalMediaItemsCount: images.count,countLabelPosition: countLabelPosition)
        
        // Add constraints
        self.addConstraints(itemsMargin: itemsMargin)
    }
    
    /**
     Setup multiple images view
     - parameter images: The NJImage array to load
     - parameter countLabelPosition: count label position
     - parameter placeHolderImage: place holder image to use when failed to load image
     - parameter itemsMargin: The margin between images
     */
    public func setup(images : [JNImage] , countLabelPosition : JNMultipleImagesCountLabelPosition = JNMultipleImagesCountLabelPosition.bottomRight , placeHolderImage : UIImage? = nil , itemsMargin : CGFloat = 2.0) {
        
        // Reset view
        self.resetView()
        
        var count = 0
        
        for mediaItem in images {
            
            // Create media view
            let mediaView = self.createMediaView(mediaItem: mediaItem,placeHolderImage: placeHolderImage)
            
            // Set media view tag
            mediaView.tag = count
            
            // Add media view
            self.imagesContainerView.addSubview(mediaView)
            
            // Increment count
            count += 1
            
            // Check if 4 items created break loop
            if self.imagesContainerView.subviews.count == 4 {
                break
            }
        }
        
        // Setup count label
        self.setupCountLabel(totalMediaItemsCount: images.count,countLabelPosition: countLabelPosition)
        
        // Add constraints
        self.addConstraints(itemsMargin: itemsMargin)
    }
    
    /**
     Setup count label
     - parameter totalMediaItemsCount: The total count of the media array
     - parameter countLabelPosition: count label position
     */
    private func setupCountLabel(totalMediaItemsCount:Int,countLabelPosition : JNMultipleImagesCountLabelPosition) {
        
        // Add count label if number of item more than the limit
        if totalMediaItemsCount > 4 {
            
            // Setup count label
            let numberOfExtraMedia = totalMediaItemsCount - 4
            self.countLabel.text = "+" + numberOfExtraMedia.description
            self.countLabel.isHidden = false
            
            // Add count label constraint
            self.addCountLabelConstraint(countLabelPosition: countLabelPosition)
        }
    }
    
    /**
     Create media view
     - parameter mediaItem: The JNImage to apply to the UIImageView
     - parameter placeHolderImage: place holder image to use when failed to load image
     - returns : UIImageView instance
     */
    private func createMediaView(mediaItem : JNImage , placeHolderImage : UIImage?) -> UIImageView {
        
        var imagesPlaceHolder = placeHolderImage
        
        // Set default placeholder image
        if imagesPlaceHolder == nil {
            let bundle = Bundle(for: JNMultipleImagesView.self)
            imagesPlaceHolder = UIImage(named: "BrokenImageDefaultPlaceholder", in: bundle, compatibleWith: nil)
        }
        
        let mediaView = UIImageView(image: imagesPlaceHolder)
        
        // Enable user interactions
        mediaView.isUserInteractionEnabled = true
        
        // Add tap gesture to the media view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didClickMediaView(gestureRecognizer:)))
        mediaView.addGestureRecognizer(tapGesture)
        
        // Set background color
        mediaView.backgroundColor = UIColor.clear
        
        // Get image
        if let image = mediaItem.image {
            
            // Set image
            mediaView.image = image
        } else if !mediaItem.url.isEmpty , let url = URL(string: mediaItem.url) {
            
            // Load image
            mediaView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
            mediaView.sd_setShowActivityIndicatorView(true)
            
            // Set image
            mediaView.sd_setImage(with: url, placeholderImage: imagesPlaceHolder, options: [], completed: { (image, error, cashe, url) in
                
                if let error = error , let imageUrl = url {
                    
                    // Set place holder image
                    mediaView.image = imagesPlaceHolder
                    
                    // Call delegate
                    if self.delegate != nil {
                        self.delegate?.jsMultipleImagesView?(failedToLoadImage: imageUrl.absoluteString, error: error)
                    }
                } else if let image = image , let imageUrl = url {
                    
                    // Set image
                    mediaView.image = image
                    
                    // Call delegate
                    if self.delegate != nil {
                        self.delegate?.jsMultipleImagesView?(didLoadImage: imageUrl.absoluteString, image: image)
                    }
                }
                
                // Adjust media view content mode
                self.adjustImageViewContentModeAccordingToImage(image: mediaView.image!, mediaView: mediaView)
            })
        }
        
        // Get image
        if let image = mediaView.image {
            
            // Adjust media view content mode
            self.adjustImageViewContentModeAccordingToImage(image: image, mediaView: mediaView)
        }
        
        // Clip to bounds
        mediaView.clipsToBounds = true
        
        return mediaView
    }
    
    /**
     Adjust image view content mode according uiimage
     - parameter image : The UIImage to scale
     - parameter mediaView : The UIImageView thats will to be adjusted
     */
    private func adjustImageViewContentModeAccordingToImage(image: UIImage, mediaView: UIImageView) {
        
        // Check if there is content mode set
        if let imagesContentMode = self.imagesContentMode {
            mediaView.contentMode = imagesContentMode
            return
        }
        
        let heightInPoints = image.size.height
        let heightInPixels = heightInPoints * image.scale
        
        let widthInPoints = image.size.width
        let widthInPixels = widthInPoints * image.scale
        
        let firstCondition = (widthInPixels < mediaView.frame.size.width) && (heightInPixels < mediaView.frame.size.height)
        let secondCondtion = (heightInPixels / widthInPixels) < (mediaView.frame.size.height / mediaView.frame.size.width)
        let thirdCondition = CGFloat(widthInPoints / heightInPixels) < (mediaView.frame.size.width / mediaView.frame.size.height)
        
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
    
    /**
     Did click item at index
     - parameter atIndex: The clicked item index
     */
    @objc optional func jsMultipleImagesView(didClickItem atIndex : Int)
}
