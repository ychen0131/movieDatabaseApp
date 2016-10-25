//
//  MovieDetailViewController.swift
//  Lab4
//
//  Created by You Chen on 10/15/16.
//  Copyright © 2016 You Chen. All rights reserved.
//

import UIKit
import Social

class MovieDetailViewController: UIViewController {

    var imdbID: String = ""
    var movieObj : Info = Info(title: "", year: "", posterUrl: "", imdbID: "", posterImg: UIImage(), rating: "", released: "", score: "")
    
    @IBOutlet weak var posterImg: UIImageView!
    
    @IBOutlet weak var ReleasedLabel: UILabel!
    
    @IBOutlet weak var ScoreLabel: UILabel!
    @IBOutlet weak var RatingLabel: UILabel!
    
    @IBOutlet weak var AddToFavBtn: UIButton!
    
    @IBAction func showShareOptions(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "", message: "Share your Note", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        
        // Configure a new action for sharing the note in Twitter.
        let tweetAction = UIAlertAction(title: "Share on Twitter", style: UIAlertActionStyle.Default) { (action) -> Void in
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
                // Initialize the default view controller for sharing the post.
                let twitterComposeVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                twitterComposeVC.setInitialText("\(self.movieObj.title) / Score: \(self.movieObj.score)")
                twitterComposeVC.addImage(self.movieObj.posterImg)
                self.presentViewController(twitterComposeVC, animated: true, completion: nil)
            }
            else {
                self.showAlertMessage("You are not logged in to your Twitter account.")
            }

        }
        // Configure a new action to share on Facebook.
        let facebookPostAction = UIAlertAction(title: "Share on Facebook", style: UIAlertActionStyle.Default) { (action) -> Void in
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
                let facebookComposeVC = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                facebookComposeVC.setInitialText("\(self.movieObj.title) / Score: \(self.movieObj.score)")
                facebookComposeVC.addImage(self.movieObj.posterImg)
                self.presentViewController(facebookComposeVC, animated: true, completion: nil)
            }
            else {
                self.showAlertMessage("You are not connected to your Facebook account.")
            }
        }
        
        // Configure a new action to show the UIActivityViewController
        let moreAction = UIAlertAction(title: "More", style: UIAlertActionStyle.Default) { (action) -> Void in
            let activityViewController = UIActivityViewController(activityItems: [self.movieObj.title], applicationActivities: nil)
            activityViewController.excludedActivityTypes = [UIActivityTypeMail]
            self.presentViewController(activityViewController, animated: true, completion: nil)
        }
        let dismissAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) { (action) -> Void in
            
        }
        
        actionSheet.addAction(tweetAction)
        actionSheet.addAction(facebookPostAction)
        actionSheet.addAction(moreAction)
        actionSheet.addAction(dismissAction)
        
        presentViewController(actionSheet, animated: true, completion: nil)


    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftItemsSupplementBackButton = true;
        
        posterImg.image = movieObj.posterImg
        posterImg.contentMode = .ScaleAspectFit
        ReleasedLabel.text = "Released: \(movieObj.released)"
        ScoreLabel.text = "Score: \(movieObj.score)"
        RatingLabel.text = "Rating: \(movieObj.rating)"

        self.navigationItem.title = movieObj.title

        
        AddToFavBtn.addTarget(self, action: #selector(addToFav(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func loadMovies() -> [String]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Info.ArchiveURL.path!) as? [String]
    }

    
    
    func addToFav(btn: UIButton){
        if (!MoviesCollectionViewController.GlobalVariables.dataArray.contains(movieObj.title)) {
            MoviesCollectionViewController.GlobalVariables.dataArray.append(movieObj.title)
            let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(MoviesCollectionViewController.GlobalVariables.dataArray, toFile: Info.ArchiveURL.path!)
            if !isSuccessfulSave {
                print("Failed to save ...")
            } else {
                print("saved \(MoviesCollectionViewController.GlobalVariables.dataArray)")
            }
        } else {
            
        }
        
    }
    
    
    func showAlertMessage(msg: String) {
        let alertController = UIAlertController(title: "Alert", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)

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
