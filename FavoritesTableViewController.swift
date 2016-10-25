//
//  FavoritesTableViewController.swift
//  Lab4
//
//  Created by You Chen on 10/16/16.
//  Copyright © 2016 You Chen. All rights reserved.
//

import UIKit

class FavoritesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var strLabel = UILabel()
    var messageFrame = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.userInteractionEnabled = true
        self.navigationItem.leftItemsSupplementBackButton = true
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
        if (MoviesCollectionViewController.GlobalVariables.dataArray.count == 0) {
            self.strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 200, height: 50))
            self.strLabel.text = "No Favorites Added"
            self.strLabel.textColor = UIColor.blackColor()
            messageFrame = UIView(frame: CGRect(x: self.tableView.frame.midX - 120, y: self.view.frame.midY - 25 , width: 240, height: 50))
            messageFrame.backgroundColor = UIColor(white: 0, alpha: 0.0)
            messageFrame.addSubview(strLabel)
            self.tableView.addSubview(messageFrame)
        } else {
            messageFrame.removeFromSuperview()
        }


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MoviesCollectionViewController.GlobalVariables.dataArray.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("mycell")
        cell!.textLabel?.text = MoviesCollectionViewController.GlobalVariables.dataArray[indexPath.row]
        return cell!
    }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            // Delete the row from the data source
            MoviesCollectionViewController.GlobalVariables.dataArray.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)

            
            let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(MoviesCollectionViewController.GlobalVariables.dataArray, toFile: Info.ArchiveURL.path!)
            if !isSuccessfulSave {
                print("Failed to save...")
            }
            
            // Show msg if there are no favorites
            if (MoviesCollectionViewController.GlobalVariables.dataArray.count == 0) {
                self.strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 200, height: 50))
                self.strLabel.text = "No Favorites Added"
                self.strLabel.textColor = UIColor.blackColor()
                messageFrame = UIView(frame: CGRect(x: self.tableView.frame.midX - 120, y: self.view.frame.midY - 25 , width: 240, height: 50))
                messageFrame.backgroundColor = UIColor(white: 0, alpha: 0.0)
                messageFrame.addSubview(strLabel)
                self.tableView.addSubview(messageFrame)
            } else {
                messageFrame.removeFromSuperview()
            }


        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    private func getJSON(url: String) -> JSON {
        
        if let nsurl = NSURL(string: url){
            if let data = NSData(contentsOfURL: nsurl) {
                let json = JSON(data: data)
                return json
            } else {
                return nil
            }
        } else {
            return nil
        }
        
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
