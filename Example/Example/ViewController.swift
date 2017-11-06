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

    // Multiple images view
    @IBOutlet weak var multipleImagesView: JNMultipleImagesView!
 
    var itemIndex = 0
    
    let images  = ["https://static.pexels.com/photos/257360/pexels-photo-257360.jpeg",
                   "https://www.colourbox.com/preview/13199581-fresh-and-green-beautiful-of-summer-blooming-yellow-flowers-tunnel-in-park-golden-shower-cassia-fistula-perspective-land-scape-use-for-natural-background-backdrop.jpg",
                   "https://images.pexels.com/photos/514241/pexels-photo-514241.jpeg?w=1260&h=750&dpr=2&auto=compress&cs=tinysrgb",
                   "https://www-tc.pbs.org/wnet/nature/files/2017/03/1007.jpg",
                   "https://i.pinimg.com/736x/53/62/a9/5362a940ab654152d8411b0d2f56d874--sunrise-pictures-nature-pictures.jpg"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Clear images cache
        self.multipleImagesView.clearImagesCache()
        
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
        self.multipleImagesView.setup(images: imagesArray, countLabelPosition: itemIndex > 4 ? JNMultipleImagesCountLabelPosition.fullScreen : JNMultipleImagesCountLabelPosition.bottomRight)
        
        // Add border to multiple images view
        self.multipleImagesView.layer.borderWidth = 2
        self.multipleImagesView.layer.borderColor = UIColor.gray.cgColor
        
        // Setup count label
        self.multipleImagesView.countLabel.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
        self.multipleImagesView.countLabel.textColor = UIColor.white
        self.multipleImagesView.countLabel.font = UIFont.systemFont(ofSize: 23)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
