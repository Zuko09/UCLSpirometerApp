//
//  RecordingsViewController.swift
//  SpirometerApp
//
//  Created by Varun Kumar Viswanth on 1/13/17.
//  Copyright © 2017 Varun Kumar Viswanth. All rights reserved.
//

import Foundation

import UIKit

class RecordingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var files: [String] = [String]()
    var urls: [URL] = [URL]()
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return(files.count)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = files[indexPath.row]
        return cell
    }
    
    
    // This function gets the URL for the documents directory.
    func getDocumentsDirectory() -> [URL] {
        // Get the document directory url
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        var results:[URL] = [documentsUrl]
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            //print(directoryContents)
            let wavFiles = directoryContents.filter{ $0.pathExtension == "wav" }
            results = wavFiles
            return results
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return results
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let url:URL = urls[indexPath.row]
            let filename = url.relativeString
        
            let alertController = UIAlertController(title: "Confirm Delete", message:
                "Are you sure you want to delete \(filename)", preferredStyle: UIAlertControllerStyle.alert)
            let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default,handler: {action in
                do {
                    try FileManager.default.removeItem(at: url)
                } catch {
                    print("remove item \(filename)")
                }
                self.urls = self.getDocumentsDirectory()
                self.files = self.urls.map{ $0.deletingPathExtension().lastPathComponent}
                tableView.reloadData()
            })
            
            alertController.addAction(deleteAction)
            alertController.view.tintColor = UIColor.red
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
   
    
    override func viewWillAppear(_ animated: Bool) {
        urls = getDocumentsDirectory()
        files = urls.map{ $0.deletingPathExtension().lastPathComponent}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
