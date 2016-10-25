//
//  SearchController.swift
//  Lab4
//
//  Created by You Chen on 10/13/16.
//  Copyright © 2016 You Chen. All rights reserved.
//
//  Creative Portion: users can share the movie to their social networks,
//                    display a message if there are no results / favorites,
//                    allow the user to filter by release year

import UIKit


class MoviesCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,  UISearchBarDelegate, UISearchDisplayDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var collectionView: UICollectionView!
    
    
    var queue = NSOperationQueue()
    
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    var messageFrame = UIView()
    var messageFrameNoResults = UIView()

    
    var theData: [Info] = []
    var theImageCache: [String: UIImage] = [:]
    
    // filter set default to not applied
    var filterApplied = false
    var filteredData :[Info] = []
    
    struct GlobalVariables {
        static var dataArray : [String] = (NSKeyedUnarchiver.unarchiveObjectWithFile(Info.ArchiveURL.path!) as? [String])!
    }
    
    
    
    @IBAction func Filter(sender: UIButton) {
        self.presentViewController(alert, animated: true, completion: {})
    }
    
    var startYearTextField: UITextField!
    var endYearTextField: UITextField!
    var alert = UIAlertController(title: "Enter Year Range", message: "", preferredStyle: .Alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        alert.addTextFieldWithConfigurationHandler(startYearConfig)
        alert.addTextFieldWithConfigurationHandler(endYearConfig)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler:handleCancel))
        alert.addAction(UIAlertAction(title: "Apply Filter", style: .Default, handler:{ (UIAlertAction) in
            self.filterApplied = true
            self.Filter()
            self.collectionView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Clear Filter", style: .Default, handler:{ (UIAlertAction) in
            self.startYearTextField.text=""
            self.endYearTextField.text=""
            self.filterApplied = false
            self.collectionView.reloadData()
        }))

        
        self.searchBar.delegate = self
        self.searchBar.enablesReturnKeyAutomatically = false
        self.collectionView!.collectionViewLayout = getLayout()
        self.collectionView?.backgroundColor = UIColor.whiteColor()
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        self.navigationItem.leftItemsSupplementBackButton = true
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationItem.title = "Movie"

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    func startYearConfig(textField: UITextField!)
    {
        textField.placeholder = "start year"
        startYearTextField = textField
    }
    
    func endYearConfig(textField: UITextField!)
    {
        textField.placeholder = "end year"
        endYearTextField = textField
    }
    
    func handleCancel(alertView: UIAlertAction!)
    {
    }
    
    
    // Filter the Existing Data Array
    func Filter() {
        self.filteredData = theData.filter({
            Int($0.year) > Int(startYearTextField.text!) && Int($0.year) < Int(endYearTextField.text!)
        })
    }
    

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.messageFrame.removeFromSuperview()
        self.messageFrameNoResults.removeFromSuperview()
        self.queue.cancelAllOperations()
        
        
        
        // add a spinner when pulling data
        self.strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 200, height: 50))
        self.strLabel.text = "Loading Data"
        self.strLabel.textColor = UIColor.whiteColor()
        self.messageFrame = UIView(frame: CGRect(x: self.collectionView.frame.midX - 90, y: self.view.frame.midY - 25 , width: 180, height: 50))
        self.messageFrame.layer.cornerRadius = 15
        self.messageFrame.backgroundColor = UIColor(white: 0, alpha: 0.7)
        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        self.activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        self.activityIndicator.startAnimating()
        self.messageFrame.addSubview(self.activityIndicator)
        self.messageFrame.addSubview(self.strLabel)
        self.view.addSubview(self.messageFrame)
        
        searchWhenTextChanged()
        
        

    }
    
    
    func searchWhenTextChanged() {
        self.messageFrameNoResults.removeFromSuperview()
        self.queue.cancelAllOperations()

        // Multithread Operation on Searching
        let operation1 = NSBlockOperation(block: {
            self.theData = self.searchFromAPI(self.searchBar.text!)
            NSOperationQueue.mainQueue().addOperationWithBlock({
            })
        })
        
        
        operation1.completionBlock = {
            if (operation1.cancelled) {
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.collectionView?.reloadData()
                self.messageFrame.removeFromSuperview()
                
                // show a message if there are no results
                if (self.theData.count == 0) {
                    self.strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 200, height: 50))
                    self.strLabel.text = "No Results Found"
                    self.strLabel.textColor = UIColor.blackColor()
                    self.messageFrameNoResults = UIView(frame: CGRect(x: self.view.frame.midX - 120, y: self.view.frame.midY - 25 , width: 240, height: 50))
                    self.messageFrameNoResults.backgroundColor = UIColor(white: 0, alpha: 0.0)
                    self.messageFrameNoResults.addSubview(self.strLabel)
                    if (!self.messageFrameNoResults.isDescendantOfView(self.view)) {
                        self.view.addSubview(self.messageFrameNoResults)
                    }
                } else {
                    self.messageFrameNoResults.removeFromSuperview()
                }
                

            })
        }
        
        queue.addOperation(operation1)
        

    }
    
    
    
    func searchFromAPI(word: String) -> [Info] {
        
        var newDataArray: [Info] = []
        
        let json = getJSON("http://www.omdbapi.com/?s=" + word)
        
        
        for result in json["Search"].arrayValue {
            let title = result["Title"].stringValue
            let year = result["Year"].stringValue
            let posterUrl = result["Poster"].stringValue
            let imdbID = result["imdbID"].stringValue
            
            var image = UIImage()
            
            if let url = NSURL(string:posterUrl) {
                if let data = NSData(contentsOfURL: url){
                    image = UIImage(data: data)!
                    theImageCache[imdbID] = image
                }
            }
            
            var json = getJSON("http://www.omdbapi.com/?i=" + imdbID + "&plot=short&r=json")
            
            let rating = json["Rated"]
            let release = json["Released"]
            let score = json["imdbRating"]
            
            newDataArray.append(Info(title: title, year: year, posterUrl: posterUrl, imdbID: imdbID, posterImg: image, rating: rating.stringValue, released: release.stringValue, score: score.stringValue))
            
            
        }
        

        let json2 = getJSON("http://www.omdbapi.com/?s=" + word + "&page=2")

        for result in json2["Search"].arrayValue {

            let title = result["Title"].stringValue
            let year = result["Year"].stringValue
            let posterUrl = result["Poster"].stringValue
            let imdbID = result["imdbID"].stringValue
            
            var image = UIImage()
            
            if let url = NSURL(string:posterUrl) {
                if let data = NSData(contentsOfURL: url){
                    image = UIImage(data: data)!
                    theImageCache[imdbID] = image
                }
            }
            
            var json = getJSON("http://www.omdbapi.com/?i=" + imdbID + "&plot=short&r=json")
            
            let rating = json["Rated"]
            let release = json["Released"]
            let score = json["imdbRating"]
            
            newDataArray.append(Info(title: title, year: year, posterUrl: posterUrl, imdbID: imdbID, posterImg: image, rating: rating.stringValue, released: release.stringValue, score: score.stringValue))
            
            
        }
        

        let json3 = getJSON("http://www.omdbapi.com/?s=" + word + "&page=3")

        for result in json3["Search"].arrayValue {

            let title = result["Title"].stringValue
            let year = result["Year"].stringValue
            let posterUrl = result["Poster"].stringValue
            let imdbID = result["imdbID"].stringValue
            
            var image = UIImage()
            
            if let url = NSURL(string:posterUrl) {
                if let data = NSData(contentsOfURL: url){
                    image = UIImage(data: data)!
                    theImageCache[imdbID] = image
                }
            }
            
            var json = getJSON("http://www.omdbapi.com/?i=" + imdbID + "&plot=short&r=json")
            
            let rating = json["Rated"]
            let release = json["Released"]
            let score = json["imdbRating"]
            
            newDataArray.append(Info(title: title, year: year, posterUrl: posterUrl, imdbID: imdbID, posterImg: image, rating: rating.stringValue, released: release.stringValue, score: score.stringValue))
            
            
        }
        
        return newDataArray
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (filterApplied) {
            return filteredData.count
        } else {
            return theData.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("MovieDetailSegue", sender: collectionView.cellForItemAtIndexPath(indexPath))

    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style: .Plain ,  target:nil, action:nil)
        if (segue.identifier == "MovieDetailSegue") {
            let secondController = segue.destinationViewController as! MovieDetailViewController
            let indexPath = self.collectionView.indexPathForCell(sender as! UICollectionViewCell)
            if (filterApplied) {
                secondController.imdbID = filteredData[(indexPath?.row)!].imdbID
                secondController.movieObj = filteredData[(indexPath?.row)!]
            } else {
                secondController.imdbID = theData[(indexPath?.row)!].imdbID
                secondController.movieObj = theData[(indexPath?.row)!]
            }
        }

    }
    
    
    // collectionView Layout Configuration
    func getLayout() -> UICollectionViewLayout
    {
        let layout:UICollectionViewFlowLayout =  UICollectionViewFlowLayout()
        
        let itemsPerRow : CGFloat = 3
        let sectionInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 50.0, right: 5.0)
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = self.view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow

        layout.itemSize = CGSize(width: widthPerItem, height: widthPerItem/11*17)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 50.0, right: 5.0)
        
        return layout as UICollectionViewLayout
        
    }

    
    
    // collecionView Cells Configuration
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("mycell", forIndexPath: indexPath)
        cell.backgroundColor=UIColor.blackColor()
        
        if (filterApplied) {
            let imageView = UIImageView(image: theImageCache[filteredData[indexPath.row].imdbID])
            imageView.contentMode = .ScaleAspectFill
            cell.backgroundView = imageView
            let titleLabel: UILabel = UILabel(frame: CGRect(origin: CGPoint(x:0, y: cell.frame.height-30), size: CGSize(width: cell.frame.width, height: 30)))
            titleLabel.text = filteredData[indexPath.row].title
            titleLabel.textColor = UIColor.whiteColor()
            titleLabel.backgroundColor = UIColor.blackColor()
            titleLabel.opaque = true
            titleLabel.font = titleLabel.font.fontWithSize(10)
            titleLabel.textAlignment = NSTextAlignment.Center;
            titleLabel.numberOfLines = 0;
            cell.addSubview(titleLabel)
        } else {
            let imageView = UIImageView(image: theImageCache[theData[indexPath.row].imdbID])
            imageView.contentMode = .ScaleAspectFill
            cell.backgroundView = imageView
            let titleLabel: UILabel = UILabel(frame: CGRect(origin: CGPoint(x:0, y: cell.frame.height-30), size: CGSize(width: cell.frame.width, height: 30)))
            titleLabel.text = theData[indexPath.row].title
            titleLabel.textColor = UIColor.whiteColor()
            titleLabel.backgroundColor = UIColor.blackColor()
            titleLabel.opaque = true
            titleLabel.font = titleLabel.font.fontWithSize(10)
            titleLabel.textAlignment = NSTextAlignment.Center;
            titleLabel.numberOfLines = 0;
            cell.addSubview(titleLabel)
        }

        return cell
    }
    
    func getPoster(title: String) -> UIImage {
        for data in theData {
            if (data.title == title) {
                return theImageCache["\(data.imdbID)"]!
            }
        }
        return UIImage()
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
