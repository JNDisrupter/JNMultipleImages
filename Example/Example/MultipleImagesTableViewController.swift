//
//  MultipleImagesTableViewController.swift
//  Example
//
//  Created by Mohammad Nabulsi on 11/6/17.
//  Copyright © 2017 JNDisrupter. All rights reserved.
//

import UIKit

class MultipleImagesTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set footer view
        self.tableView.tableFooterView = UIView()
        
        // Set navigation item back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ShowExample", sender: indexPath.row)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if let destination = segue.destination as? ViewController , segue.identifier == "ShowExample" , let index = sender as? Int {
            destination.itemIndex = index
        }
    }

}
