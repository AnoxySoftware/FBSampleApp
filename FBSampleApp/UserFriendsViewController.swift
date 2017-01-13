//
//  UserFriendsViewController.swift
//  FBSampleApp
//
//  Created by Eleftherios Charitou on 12/01/17.
//  Copyright © 2017 Anoxy Software. All rights reserved.
//

import UIKit
import FBSDKCoreKit

class UserFriendsViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    fileprivate var userFBData : FBUser!
    
    fileprivate var retryCounter  = 0
    fileprivate let maxRetries = 3
    fileprivate var cellSize : CGSize!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Collection view data source
    var dataSource = FriendsCVDataSource(friends: [],cellIdentifier: "FBCollectionCell", configureCell: {cell, user in
        cell.nameLabel.text = user.name
    })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.collectionView.dataSource = dataSource
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.precalculateCellSize(forSize: self.collectionView.bounds.size)
        self.collectionView.collectionViewLayout.invalidateLayout()
        
        if FBSDKAccessToken.current() == nil {
            // User is not logged in, kick him back to the login screen
            self.kickUserBackToMain()
        }
        else {
            //see if we have the user data, else populate it
            LoadingOverlay.shared.showOverlay(view:self.view)
            self.getUserFBDataIfNeeded()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.precalculateCellSize(forSize: size)
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    //MARK: - Initialization helpers
    func precalculateCellSize(forSize size: CGSize) {
        
        //get our flow layout
        let flowLayout: UICollectionViewFlowLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        //get our margins
        let margins: CGFloat = flowLayout.sectionInset.left + flowLayout.sectionInset.right
        
        //caclulate the available width
        let availableWidth: CGFloat = size.width - margins - 2 * flowLayout.minimumInteritemSpacing
        
        //now see how many rows we will have, we want our cell width to be at least 280 pixels, but never less than 1  of course
        let numberOfRows = max(floor(availableWidth/280),1)
        
        //we set the height at 100pixels
        cellSize = CGSize(width: availableWidth/numberOfRows, height: 100)
    }
    
    func getUserFBDataIfNeeded(completionHandler:((Any?, Error?) -> ())? = nil) {
        
        if userFBData == nil {
            let graphRequest:FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id,about,birthday,email,first_name,last_name,name,gender,location,relationship_status,picture.width(800).height(600)"])
            
            graphRequest.start(completionHandler: { (connection, result, error) -> Void in
                
                
                if error != nil {
                    #if DEBUG
                        print("Error getting the user's profile data from Facebook:\n\(error)")
                    #endif
                    
                    //show the error message to the user and then try again
                    self.showErrorMessage(error: error!, completionHandler:{ retry in
                        if retry == true {
                            self.getUserFBDataIfNeeded()
                        }
                    })
                }
                else {
                    
                    if let data:[String:AnyObject] = result as? [String : AnyObject] {
                        if let userFBData = FBUser(JSON: data) {
                            self.userFBData = userFBData
                            self.getUsersFriends()
                        }
                        else {
                            //we couldn't get the user Data (populate the model)
                            //which means we are missing the user's name, alert the user....
                            self.showAbortMessage(title: Strings.errorAbortTitle,message: Strings.errorUserDataMissingMessage)
                        }
                    }
                    else {
                        //we didn't get any data from facebook...
                        self.showAbortMessage(title: Strings.errorAbortTitle,message: Strings.errorAbortMessage)
                    }
                    
                }
                
                //call the completion Hanlder if we have one (used in Unit Testing)
                completionHandler?(result,error)
            })
        }
        else {
            //reset the retry counter
            retryCounter = 0
            //get the user's friends list (FB Graph API v2.0 doesn't allow us to get the user's friends anymore, and you can only get invitable/taggable friends
            //but only if your app has a FB App Canvas....
            self.getUsersFriends()
        }
    }
    
    func getUsersFriends(completionHandler:((Any?, Error?) -> ())? = nil) {
        //we specific ask for the picture in 500X500 size, so it shows up nicely in all displays
        let graphRequest:FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "/me/taggable_friends?limit=1000", parameters:["fields":"id,name,picture.width(500).height(500)"])
        
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            
            if error != nil {
                #if DEBUG
                    print("Error getting the user's friends data from Facebook:\n\(error)")
                #endif
                //show the error message to the user
                self.showErrorMessage(error: error!, completionHandler:{ retry in
                    if retry == true {
                        self.getUsersFriends()
                    }
                })
            }
            else {
                if let data:[String:AnyObject] = result as? [String : AnyObject] {
                    self.parseUserFriends(data)
                }
                else {
                    //we couldn't get the users Friends Data from facebook
                    self.showAbortMessage(title: Strings.errorAbortTitle,message: Strings.errorAbortMessage)
                }
            }
            
            //call the completion Hanlder if we have one (used in Unit Testing)
            completionHandler?(result,error)
        })
    }
    
    //MARK: - Data Parsing
    func parseUserFriends(_ data:[String : AnyObject]) {
        
        var friendsArray : [FBUser] = []
        
        //try to parse friends
        if let data = data["data"] as? [[String: AnyObject]] {
            
            for userData:[String: AnyObject] in data {
                if let friend = FBUser(JSON: userData) {
                    friendsArray.append(friend)
                }
            }
            
            //set our photos array if we have any photos
            if friendsArray.count>0 {
                self.updateCollectionByAppendingUsers(friendsArray)
            }
            
            LoadingOverlay.shared.hideOverlayView()
        }
    }
    
    //MARK - UICollectionView DataSource Helpers
    
    func resetCollection() {
        dataSource.friends = []
        collectionView.reloadData()
    }
    
    //function to add items to our datasource
    //it will automatically reload the data or append it if we are adding paging data
    func updateCollectionByAppendingUsers(_ users: [FBUser]) {
        //if we don't have any data, just reload the collectionView
        guard dataSource.friends.count > 0 else {
            dataSource.friends = users
            collectionView.reloadData()
            return
        }
        
        //else we need to insert the indexPaths
        collectionView.performBatchUpdates({
            let countBefore = self.dataSource.friends.count
            self.dataSource.friends.append(contentsOf: users)
            let countAfter = self.dataSource.friends.count
            
            let indexPaths = (countBefore..<countAfter).map { IndexPath(item: $0, section: 0) }
            self.collectionView.insertItems(at: indexPaths)
            
        }, completion: nil)
    }
    
    //MARK: - UICollectionView Delegate
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! FBCollectionViewCell
        let user : FBUser = self.dataSource.objectAtIndexPath(indexPath)
        
        guard let imageURLString = user.profilePictureURLString else {
            return
        }
        
        let url = URL(string: imageURLString)
        let placeHolder = UIImage(named: "placeholder")
        cell.imageView.kf.setImage(with: url, placeholder:placeHolder)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! FBCollectionViewCell
        cell.imageView.kf.cancelDownloadTask()
    }
    
    //MARK: - UICollectionViewFlowLayout Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
    //MARK: - Helper functions
    ///shows an error message and takes 2 functions as parameters to execute on OK and Abort
    func showErrorMessage(error:Error, completionHandler:((Bool) -> ())?) {
        LoadingOverlay.shared.hideOverlayView()
        
        self.showAlert(title: Strings.errorGraphRequestTitle, message:String(format:Strings.errorGraphRequestMessage, error.localizedDescription) , { (buttonIndex) in
            if self.retryCounter < self.maxRetries {
                completionHandler?(true)
            }
            else {
                completionHandler?(false)
                self.showAbortMessage(title: Strings.errorAbortTitle,message: Strings.errorAbortMessage)
            }
            
        }, buttonTitles:Strings.btnOK)
        
        self.retryCounter += 1
    }
    
    func showAbortMessage(title:String,message:String) {
        LoadingOverlay.shared.hideOverlayView()
        
        self.showAlert(title: title, message:message ,
                                  { (buttonIndex) in
            //kick the user back to the main screen
            self.kickUserBackToMain()
        }, buttonTitles:Strings.btnOK)
    }
    
    func kickUserBackToMain() {
        self.performSegue(withIdentifier: "unwindToRoot", sender: self)
    }
    
    //MARK: - Localizable Strings for our ViewController
    fileprivate struct Strings {
        static let btnOK = NSLocalizedString("OK",comment: "OK button title")
        
        static let errorGraphRequestTitle = NSLocalizedString("Something went wrong", comment: "This is the alert title shown to the user if an error happens during a request to get data from Facebook")
        static let errorGraphRequestMessage = NSLocalizedString("An Error occured trying to get data from Facebook\nError:%@\n\nHit ok to try again", comment: "This is the alert message shown to the user if an error happens during a request to get data from Facebook")
        
        static let errorAbortTitle = NSLocalizedString("Houston we have a problem", comment: "This is the alert title shown to the user if we are unable to get the Facebook data of the user or his friends")
        static let errorAbortMessage = NSLocalizedString("It seems that we can't get the data from Facebook right now.\nPlease try logging in again through Facebook and make sure you are connected to the interent!", comment: "This is the alert message shown to the user if we are unable to get the Facebook data of the user or his friends")
        static let errorUserDataMissingMessage = NSLocalizedString("It seems that some of your user Data is missing from Facebook\nPlease try logging in again through Facebook\nIf this error persists, please let us know!", comment: "This is the alert message shown to the user if we are unable to get the users basic information from Facebook")
    }
}
