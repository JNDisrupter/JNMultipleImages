//
//  ViewController.swift
//  Example
//
//  Created by Mohammad Nabulsi on 10/12/17.
//  Copyright © 2017 JNDisrupter. All rights reserved.
//

import UIKit
import JNMultipleImages

class ViewController: UIViewController {

    ///  Multiple images view
    @IBOutlet weak var multipleImagesView: JNMultipleImagesView!
 
    /// Style Segment Control
    @IBOutlet weak var styleSegmentControl: UISegmentedControl!
    
    /// Selected Multiple Images View Style
    private var selectedMultipleImagesViewStyle: JNMultipleImagesView.style = .collection
    
    /// Item Index
    var itemIndex = 0
    
    let images  = ["https://static.pexels.com/photos/257360/pexels-photo-257360.jpeg",
                   "https://i.pinimg.com/originals/c2/19/53/c21953f3ad4a17d96eb80d649bc8149b.jpg",
                   "https://images.pexels.com/photos/514241/pexels-photo-514241.jpeg?w=1260&h=750&dpr=2&auto=compress&cs=tinysrgb",
                   "https://www-tc.pbs.org/wnet/nature/files/2017/03/1007.jpg",
                   "https://i.pinimg.com/736x/53/62/a9/5362a940ab654152d8411b0d2f56d874--sunrise-pictures-nature-pictures.jpg"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Clear images cache
        self.multipleImagesView.clearImagesCache()
        
        // Setup Muultiple Images View
        self.setupMultiImagesView()
        
        // Set Title
        self.title = " Example"
   
    }

    /**
     Setup Muultiple Images View
     */
    func setupMultiImagesView() {
        
        // Set background color
        self.multipleImagesView.backgroundColor = UIColor.white
        
        var imagesArray : [JNImage] = []
        
        // Build images array
        for i in 0..<min(self.images.count,itemIndex + 1) {
        
            let item = self.images[i]
            
            let image = JNImage()
            
            image.url = item
            
            imagesArray.append(image)
        }
        
        // Setup multiple images view
        self.multipleImagesView.setup(images: imagesArray, countLabelPosition: itemIndex > 4 ? JNMultipleImagesView.JNMultipleImagesCountLabelPosition.fullScreen : JNMultipleImagesView.JNMultipleImagesCountLabelPosition.lastItem, style: self.selectedMultipleImagesViewStyle, cornerRadius: 10.0, borderColor: UIColor.lightGray, borderWidth: 1.0)
        
        // Add border to multiple images view
        //self.multipleImagesView.layer.borderWidth = 2
        //self.multipleImagesView.layer.borderColor = UIColor.gray.cgColor
        
        // Setup count label
        self.multipleImagesView.countLabel.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
        self.multipleImagesView.countLabel.textColor = UIColor.white
        self.multipleImagesView.countLabel.font = UIFont.systemFont(ofSize: 23)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     Style Chnaged
     */
    @IBAction func styleChnaged(_ sender: Any) {
        
        // Set Selected Style
        if self.styleSegmentControl.selectedSegmentIndex == 0 {
            self.selectedMultipleImagesViewStyle = .collection
        }else{
            self.selectedMultipleImagesViewStyle = .stack
        }
        
        // Setup Multi Images view
        self.setupMultiImagesView()
    }
}
