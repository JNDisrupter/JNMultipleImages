//
//  JNMultipleImagesView.swift
//  JNMultipleImages
//
//  Created by JN Disrupter on 9/13/17.
//  Copyright © 2017 JN Disrupter. All rights reserved.
//

import UIKit
import SDWebImage

// Count Label Position
public enum JNMultipleImagesCountLabelPosition {
    case fullScreen
    case bottomRight
}

open class JNMultipleImagesView: UIView {
    
    // Delegate
    weak var delegate : JNMultipleImagesViewDelegate!
    
    /**
     * Setup media view
     **/
    public func setupMediaView(_ images : [JNImage] , viewSize : CGSize , countLabelBackgroundColor : UIColor , countLabelFont : UIFont , countLabelPosition : JNMultipleImagesCountLabelPosition = .bottomRight , placeHolderImage : UIImage? = nil) {
        
        var imagesPlaceHolder = placeHolderImage
        
        // Set default placeholder image
        if imagesPlaceHolder == nil {
            let bundle = Bundle(for: JNMultipleImagesView.self)
            imagesPlaceHolder = UIImage(named: "BrokenImageDefaultPlaceholder", in: bundle, compatibleWith: nil)
        }
        
        // Clear all sub view in media container
        for view in self.subviews {
            view.removeFromSuperview()
        }
        
        var width = viewSize.width
        var height = viewSize.height
        var subImagesHeight:CGFloat = 0
        var subImageWidth:CGFloat = 0
        
        // Set media item width and height and sub media height
        if images.count >= 2 {
            
            if images.count > 2 {
                subImageWidth = viewSize.width / CGFloat(images.count > 3 ? 3 : images.count - 1)
                subImagesHeight = viewSize.height / 3
                height = height - subImagesHeight
            } else {
                width = width / 2
            }
        }
        
        for i in 0..<(images.count >= 4 ? 4 : images.count) {
            
            let mediaView = UIImageView()
            
            mediaView.tag = i
            
            // Set background color
            mediaView.backgroundColor = UIColor.black
            
            // Calculate media view frame
            if images.count == 1 {
                mediaView.frame = CGRect(x: 0, y: 0, width: width, height: height)
            }
                // In case Two Images
            else if images.count == 2 {
                mediaView.frame = CGRect(x: (CGFloat(i) * width) + (CGFloat(i) * 2), y: 0, width: width - (CGFloat(i) * 2), height: height)
            }
                //In Case More than Two Images
            else {
                if i == 0 {
                    mediaView.frame = CGRect(x: 0, y: 0, width: width, height: height)
                } else {
                    let x :CGFloat = CGFloat(i - 1) *  (subImageWidth) + (CGFloat(i - 1) * 2)
                    mediaView.frame = CGRect(x: x , y: height + 2 , width: subImageWidth , height: subImagesHeight)
                }
            }
            
            // Get media item
            let mediaItem = images[i]
            
            if mediaItem.image != nil {
                let heightInPoints = mediaItem.image?.size.height
                let heightInPixels = (heightInPoints! * (mediaItem.image?.scale)!)
                
                let widthInPoints = mediaItem.image?.size.width
                let widthInPixels = widthInPoints! * (mediaItem.image?.scale)!
                
                let firstCondition = widthInPixels < mediaView.frame.size.width && heightInPixels < mediaView.frame.size.height
                let secondCondtion = (heightInPixels / widthInPixels) < mediaView.frame.size.height / mediaView.frame.size.width
                let thirdCondition = CGFloat(widthInPoints! / heightInPixels) < mediaView.frame.size.width / mediaView.frame.size.height
                
                // Set image content mode according image width and height
                if firstCondition || secondCondtion || thirdCondition {
                    
                    // Set content mode
                    mediaView.contentMode = UIViewContentMode.scaleAspectFill
                    
                } else if widthInPoints! > heightInPixels {
                    
                    // Set content mode
                    mediaView.contentMode = UIViewContentMode.topRight
                    
                } else {
                    
                    // Set content mode
                    mediaView.contentMode = UIViewContentMode.scaleAspectFill
                }
                
                // Load image
                mediaView.image =  mediaItem.image
            } else {
                
                // Set image content mode according image width and height
                if (mediaItem.width < Int(mediaView.frame.size.width) && mediaItem.height < Int(mediaView.frame.size.height)) || (CGFloat(mediaItem.height / mediaItem.width) < mediaView.frame.size.height / mediaView.frame.size.width) || (CGFloat(mediaItem.width / mediaItem.height) < mediaView.frame.size.width / mediaView.frame.size.height) {
                    
                    // Set content mode
                    mediaView.contentMode = UIViewContentMode.scaleAspectFill
                    
                } else if mediaItem.width > mediaItem.height {
                    
                    // Set content mode
                    mediaView.contentMode = UIViewContentMode.topRight
                    
                } else {
                    
                    // Set content mode
                    mediaView.contentMode = UIViewContentMode.scaleAspectFill
                }
                
                // Load image
                mediaView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.white)
                mediaView.sd_setShowActivityIndicatorView(true)
                
                let url = URL(string: mediaItem.url)
                
                // Get image for url from cache
                let image = SDImageCache.shared().imageFromDiskCache(forKey: url?.absoluteString)
                
                // Check if image exists in cache or not
                if image == nil {
                    
                    mediaView.sd_setImage(with: url , completed: { (image, error, cashe, url) in
                        
                        if error != nil {
                            mediaView.image = imagesPlaceHolder
                        } else if let image = image , let imageUrl = url {
                            
                            // Call delegate
                            if self.delegate != nil && self.delegate.responds(to: #selector(JNMultipleImagesViewDelegate.jsMultipleImagesView(didLoadImage:image:))) {
                                self.delegate.jsMultipleImagesView!(didLoadImage: imageUrl.absoluteString, image: image)
                            }
                        }
                    })
                } else {
                    
                    // Set image
                    mediaView.image = image
                    
                    if let image = image , let imageUrl = url {
                        
                        // Call delegate
                        if self.delegate != nil && self.delegate.responds(to: #selector(JNMultipleImagesViewDelegate.jsMultipleImagesView(didLoadImage:image:))) {
                            self.delegate.jsMultipleImagesView!(didLoadImage: imageUrl.absoluteString, image: image)
                        }
                    }
                }
            }
            
            // Clip to bounds
            mediaView.clipsToBounds = true
            
            // Add media view
            self.addSubview(mediaView)
        }
        
        // Add count label if number of item more than the limit
        if images.count > 4 {
            
            // Add plus more view
            if let lastImageView = self.viewWithTag(3) {
                
                // Get button postion
                var moreButtonFrame = lastImageView.frame
                
                if countLabelPosition == .fullScreen {
                    moreButtonFrame = CGRect(x: 0, y: 0, width: viewSize.width, height: viewSize.height)
                }
                
                // Create more button
                let moreButton  = UIButton(frame: moreButtonFrame)
                moreButton.backgroundColor = countLabelBackgroundColor
                
                // Chenge font and set title
                moreButton.titleLabel?.font = countLabelFont
                let numberOfExtraMedia = images.count - 4
                moreButton.setTitle("+" + numberOfExtraMedia.description, for: UIControlState())
                
                // disable interactions
                moreButton.isUserInteractionEnabled = false
                
                // Add more button to view
                self.addSubview(moreButton)
            }
        }
    }
}

// JN Multiple Images View Delegate
@objc public protocol JNMultipleImagesViewDelegate : NSObjectProtocol {
    
    // Did load image
    @objc optional func jsMultipleImagesView(didLoadImage imageUrl : String , image : UIImage)
}
