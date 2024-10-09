//
//  JNMultipleImagesView.swift
//  JNMultipleImages
//
//  Created by JN Disrupter on 9/13/17.
//  Copyright © 2017 JN Disrupter. All rights reserved.
//

import UIKit
import SDWebImage

// MARK: -
extension JNMultipleImagesView {
    
    /**
     Count Label Position.
     
     ````
     case fullScreen
     case bottomRight
     case onLastItem
     ````
     */
    public enum JNMultipleImagesCountLabelPosition {
        
        /// Show label on the whole view.
        case fullScreen
        
        /// Last item
        case lastItem
    }
    
    /**
     Style
     
     ````
     case collection
     case stack
     ````
     */
    public enum style {
        
        /// Collection, shows as a collection
        case collection
        
        /// Stack horezintally or vertically
        case stack
    }
}

/// Multiple images view
open class JNMultipleImagesView: UIView {
    
    /// Images container view
    @IBOutlet private weak var imagesContainerView: UIView!
    
    /// Count label
    @IBOutlet public weak var countLabel: UILabel!
    
    /// Images content mode
    public var imagesContentMode: UIView.ContentMode?
    
    /// Delegate
    public weak var delegate : JNMultipleImagesViewDelegate?
    
    /// Multiple images view configuration
    private(set) var configuration: JNMultipleImagesViewConfiguration!
    
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
                
                // Corner radius
                view.layer.cornerRadius = self.configuration.cornerRadius
                
                // Set border color
                view.layer.borderColor = self.configuration.borderColor.cgColor
                
                // set border width
                view.layer.borderWidth = self.configuration.borderWidth
            }
        }
        
        // Corner radius
        self.countLabel.layer.cornerRadius = self.configuration.cornerRadius
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
        SDImageCache.shared.clearMemory()
        
        // Clear disk cache
        SDImageCache.shared.clearDisk()
    }
    
    /**
     Did click media view
     */
    @objc private func didClickMediaView(gestureRecognizer : UIGestureRecognizer) {
        
        // Get superclass as image view
        if let mediaView = gestureRecognizer.view as? UIImageView {
            
            // Call delegate
            delegate?.jnMultipleImagesView?(didClickItem: mediaView.tag, for: self)
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
     - parameter configuration: Multiple images view configuration
     */
    public func setup(images: [JNImage], configuration: JNMultipleImagesViewConfiguration) {
        
        // Reset view
        self.resetView()
        
        // Set configuration
        self.configuration = configuration
        
        // Max number of views
        var maxNumberOfViews = 4
        
        switch configuration.style {
        case .collection:
            maxNumberOfViews = 4
        case .stack:
            maxNumberOfViews = 3
        }
        
        for (index, media) in images.enumerated() {
            
            // Create media view
            let mediaView = self.createMediaView(mediaItem: media, placeHolderImage: configuration.placeHolderImage)
            
            // Set media view tag
            mediaView.tag = index
            
            // Add media view
            self.imagesContainerView.addSubview(mediaView)
            
            // Check if reached last shown index
            if index  == maxNumberOfViews - 1 {
                break
            }
        }
        
        // Setup count label
        if images.count > maxNumberOfViews {
            
            // Setup count label
            self.setupCountLabel(remainingCount: images.count - maxNumberOfViews, countLabelPosition: configuration.countLabelPosition, style: configuration.style)
        }
        
        // Add constraints
        self.addConstraints(itemsMargin: configuration.itemsMargin, style: configuration.style)
    }
    
    /**
     Setup multiple images view
     - parameter images: The NJImage array to load
     - parameter configuration: Multiple images view configuration
     */
    public func setup(images: [Any], configuration: JNMultipleImagesViewConfiguration) {
        
        // Reset view
        self.resetView()
        
        // Set configuration
        self.configuration = configuration
        
        // Max number of views
        var maxNumberOfViews = 4
        
        switch configuration.style {
        case .collection:
            maxNumberOfViews = 4
        case .stack:
            maxNumberOfViews = 3
        }
        
        for (index, media) in images.enumerated() {
            
            let jnImage = JNImage()
            
            // JNImage
            if let mediaItem = media as? UIImage {
                jnImage.image = mediaItem
               
            // String for urls
            } else if let mediaItem = media as? String {
                jnImage.url = mediaItem
            } else {
                assertionFailure("Item is not string nor JNImage")
            }
            
            // Create media view
            let mediaView = self.createMediaView(mediaItem: jnImage, placeHolderImage: configuration.placeHolderImage)
            
            // Set media view tag
            mediaView.tag = index
            
            // Add media view
            self.imagesContainerView.addSubview(mediaView)
            
            // Check if 4 items created break loop
            if self.imagesContainerView.subviews.count == maxNumberOfViews {
                break
            }
        }
        
        // Setup count label
        if images.count > maxNumberOfViews {
            
            // Setup count label
            self.setupCountLabel(remainingCount: images.count - maxNumberOfViews, countLabelPosition: configuration.countLabelPosition, style: configuration.style)
        }
        
        // Add constraints
        self.addConstraints(itemsMargin: configuration.itemsMargin, style: configuration.style)
    }
    
    /**
     Setup multiple images view
     - parameter images: The images array to load which might be string or UIImage
     - parameter countLabelPosition: count label position
     - parameter placeHolderImage: place holder image to use when failed to load image
     - parameter itemsMargin: The margin between images
     - parameter style: displaying image style
     - parameter cornerRadius: corner radius value
     - Parameter borderColor: border color
     - Parameter borderWidth: border width value
     */
    public func setup(images: [Any], countLabelPosition: JNMultipleImagesCountLabelPosition = JNMultipleImagesCountLabelPosition.lastItem, placeHolderImage: UIImage? = nil, itemsMargin: CGFloat = 2.0, style: JNMultipleImagesView.style = .collection, cornerRadius: CGFloat = 0, borderColor: UIColor = .clear, borderWidth: CGFloat = 0.0) {
     
        self.setup(images: images, configuration: JNMultipleImagesViewConfiguration(countLabelPosition: countLabelPosition, itemsMargin: itemsMargin, style: style, cornerRadius: cornerRadius, borderColor: borderColor, borderWidth: borderWidth))
    }
    
    /**
     Setup multiple images view
     - parameter images: The NJImage array to load
     - parameter countLabelPosition: count label position
     - parameter placeHolderImage: place holder image to use when failed to load image
     - parameter itemsMargin: The margin between images
     - parameter style: displaying image style
     - parameter cornerRadius: corner radius value
     - Parameter borderColor: border color
     - Parameter borderWidth: border width value
     */
    public func setup(images: [JNImage], countLabelPosition: JNMultipleImagesCountLabelPosition = JNMultipleImagesCountLabelPosition.lastItem, placeHolderImage: UIImage? = nil, itemsMargin : CGFloat = 2.0, style: JNMultipleImagesView.style = .collection, cornerRadius: CGFloat = 0, borderColor: UIColor = .clear, borderWidth: CGFloat = 0.0) {
        
        self.setup(images: images, configuration: JNMultipleImagesViewConfiguration(countLabelPosition: countLabelPosition, itemsMargin: itemsMargin, style: style, cornerRadius: cornerRadius, borderColor: borderColor, borderWidth: borderWidth))
    }
    /**
     Setup count label
     - parameter remainingCount: remaining count
     - parameter countLabelPosition: count label position
     - parameter style: JNMultiple images style
     */
    private func setupCountLabel(remainingCount: Int, countLabelPosition: JNMultipleImagesCountLabelPosition, style: JNMultipleImagesView.style) {
        
        // Setup count label
        let remainingCount = remainingCount > 99 ? 99 : remainingCount
        self.countLabel.text = "+" + remainingCount.description
        self.countLabel.isHidden = false
        
        // Corner radius
        self.countLabel.layer.cornerRadius = self.configuration.cornerRadius
        
        // Add count label constraint
        self.addCountLabelConstraint(countLabelPosition: countLabelPosition)
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
            mediaView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            
            // Set image
            mediaView.sd_setImage(with: url, placeholderImage: imagesPlaceHolder, options: [], completed: { (image, error, cashe, url) in
                
                if let error = error , let imageUrl = url {
                    
                    // Set place holder image
                    mediaView.image = imagesPlaceHolder
                    
                    // Call delegate
                    if self.delegate != nil {
                        self.delegate?.jnMultipleImagesView?(failedToLoadImage: imageUrl.absoluteString, error: error)
                    }
                } else if let image = image , let imageUrl = url {
                    
                    // Set image
                    mediaView.image = image
                    
                    // Call delegate
                    if self.delegate != nil {
                        self.delegate?.jnMultipleImagesView?(didLoadImage: imageUrl.absoluteString, image: image)
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
        
        // Set corner radius
        mediaView.layer.cornerRadius = self.configuration.cornerRadius
        
        // Set border width
        mediaView.layer.borderWidth = self.configuration.borderWidth
        
        // Set border color
        mediaView.layer.borderColor = self.configuration.borderColor.cgColor
        
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
            mediaView.contentMode = UIView.ContentMode.scaleAspectFill
        } else if widthInPoints > heightInPixels && heightInPixels < mediaView.frame.size.height {
            
            // Set content mode
            mediaView.contentMode = UIView.ContentMode.topRight
        } else {
            
            // Set content mode
            mediaView.contentMode = UIView.ContentMode.scaleAspectFit
        }
        
        // Layout media view
        mediaView.setNeedsDisplay()
    }
    
    /**
     Add constraints
     - parameter itemsMargin : Margin between images
     - parameter style : displaying images style
     */
    private func addConstraints(itemsMargin: CGFloat, style: JNMultipleImagesView.style) {
        
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
                view.widthAnchor.constraint(equalTo: self.imagesContainerView.widthAnchor, multiplier: 0.5 , constant: -itemsMargin / 2).isActive = true
            } else if views.count == 3 {
                
                switch style {
                case .stack:
                    
                    // Add constraints
                    view.topAnchor.constraint(equalTo: self.imagesContainerView.topAnchor).isActive = true
                    view.bottomAnchor.constraint(equalTo: self.imagesContainerView.bottomAnchor).isActive = true
                    
                    // Check if first item
                    if index == 0 {
                        view.leadingAnchor.constraint(equalTo: self.imagesContainerView.leadingAnchor).isActive = true
                    } else if index == 1 {
                        view.centerXAnchor.constraint(equalTo: self.imagesContainerView.centerXAnchor).isActive = true
                    } else if index == 2 {
                        view.trailingAnchor.constraint(equalTo: self.imagesContainerView.trailingAnchor).isActive = true
                    }
                    
                    // Add width constraints
                    view.widthAnchor.constraint(equalTo: self.imagesContainerView.widthAnchor, multiplier: 1/3 , constant: -itemsMargin / 3).isActive = true
                    
                case .collection:
                    
                    // Check if first item
                    if index == 0 {
                        
                        // Add constraints
                        view.leadingAnchor.constraint(equalTo: self.imagesContainerView.leadingAnchor).isActive = true
                        view.topAnchor.constraint(equalTo: self.imagesContainerView.topAnchor).isActive = true
                        view.trailingAnchor.constraint(equalTo: self.imagesContainerView.trailingAnchor).isActive = true
                        
                        // Add height constraints
                        view.heightAnchor.constraint(equalTo: self.imagesContainerView.heightAnchor, multiplier: 2/3, constant: -itemsMargin / 2).isActive = true
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
                }
            } else if views.count == 4 {
                
                // Check if first item
                if index == 0 {
                    
                    // Add constraints
                    view.leadingAnchor.constraint(equalTo: self.imagesContainerView.leadingAnchor).isActive = true
                    view.topAnchor.constraint(equalTo: self.imagesContainerView.topAnchor).isActive = true
                    view.trailingAnchor.constraint(equalTo: self.imagesContainerView.trailingAnchor).isActive = true
                    
                    // Add height constraints
                    view.heightAnchor.constraint(equalTo: self.imagesContainerView.heightAnchor, multiplier: 2/3, constant: -itemsMargin / 2).isActive = true
                } else {
                    
                    // Add constraints
                    view.bottomAnchor.constraint(equalTo: self.imagesContainerView.bottomAnchor).isActive = true
                    
                    // Get first view
                    let firstView = views[0]
                    
                    // Add leading constraint
                    view.topAnchor.constraint(equalTo: firstView.bottomAnchor, constant: itemsMargin).isActive = true
                    
                    // Add width constraints
                    view.widthAnchor.constraint(equalTo: self.imagesContainerView.widthAnchor, multiplier: 1/3 , constant:-itemsMargin * 2/3).isActive = true
                    
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
    private func addCountLabelConstraint(countLabelPosition: JNMultipleImagesCountLabelPosition) {
        
        // Get views
        let views = self.imagesContainerView.subviews
        
        // Set translate auto sizing mask
        self.countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        var targetView = self.imagesContainerView!
        
        // Check count label position
        switch countLabelPosition {
        case.lastItem:
            targetView = views.last ?? self.imagesContainerView!
        case .fullScreen:
            break
        }
        
        // Add constraints
        self.countLabel.clipsToBounds = true
        self.countLabel.leadingAnchor.constraint(equalTo: targetView.leadingAnchor).isActive = true
        self.countLabel.topAnchor.constraint(equalTo: targetView.topAnchor).isActive = true
        self.countLabel.bottomAnchor.constraint(equalTo: targetView.bottomAnchor).isActive = true
        self.countLabel.trailingAnchor.constraint(equalTo: targetView.trailingAnchor).isActive = true
    }
}

/// JNMultiple Images View Delegate
@objc public protocol JNMultipleImagesViewDelegate : NSObjectProtocol {
    
    /**
     Did load image
     - parameter imageUrl: The image url for the loaded image
     - parameter image: The uiimage object that have been loaded
     */
    @objc optional func jnMultipleImagesView(didLoadImage imageUrl : String , image : UIImage)
    
    /**
     Failed to load image
     - parameter imageUrl: The image url
     - parameter error: The error
     */
    @objc optional func jnMultipleImagesView(failedToLoadImage imageUrl : String , error : Error)
    
    /**
     Did click item at index
     - parameter atIndex: The clicked item index
     */
    @objc optional func jnMultipleImagesView(didClickItem atIndex : Int, for multipleImagesView: JNMultipleImagesView)
}
