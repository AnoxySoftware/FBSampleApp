//
//  ViewController.swift
//  FBSampleApp
//
//  Created by Eleftherios Charitou on 12/01/17.
//  Copyright © 2017 Anoxy Software. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class ViewController: UIViewController,FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    
    //the permissions we are going to be requesting
    let permissions = ["public_profile", "email", "user_friends"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if (FBSDKAccessToken.current() != nil) {
            // User is already logged in, show the friends view Controller
            self.showFriendsViewController()
        }
        else {
            //set the permissions we want to fetch
            fbLoginButton.readPermissions = permissions
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    //MARK: - FBLOGIN SDK Delegate
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        //send the result & error to the parser function
        self.parseFBLoginStatus(result: result, error: error)
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        #if DEBUG
            print("User did logout")
        #endif
        
    }
    
    //MARK - FB Login Helper Functions
    
    func requestPermissions() {
        //manually trigger login when a permission is missing
        FBSDKLoginManager().logIn(withReadPermissions: permissions, from: self, handler: { (result, error) in
            //send the result & error to the parser function
            self.parseFBLoginStatus(result: result, error: error)
        })
    }
    
    func parseFBLoginStatus(result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if (error != nil) {
            #if DEBUG
                print("Error Logging in user with Facebook:\n\(error)")
            #endif
            //show the error message to the user
            self.showAlert(title: Strings.errorPermissionsTitle, message:String(format:Strings.errorPermissionsMessage, error.localizedDescription) , nil, buttonTitles:Strings.btnOK)
        }
        else if result.isCancelled {
            //User Cancelled login....
            //we don't do anything here, but we could add a logic to handle this as well
        }
        else {
            //verify we have the user friends permission, else we need to ask again
            if result.grantedPermissions.contains("user_friends") {
                //we have our permissions
                //move on to the friends list view controller
                self.showFriendsViewController()
            }
            else {
                //log user out as he will need to login again to grant us the missing permission
                FBSDKLoginManager().logOut()
                //missing user_friends permission, alert the user and ask if he want's to retry....
                self.showPermissionAlert()
            }
        }
    }
    
    //MARK: - Helper Function
    func showPermissionAlert() {
        self.showAlert(title: Strings.missingPermissionsTitle, message: Strings.missingPermissionsMessage, { (buttonIndex) in
            if buttonIndex == 0 {
                //user allowed us to request again for permission
                self.requestPermissions()
            }
        }, buttonTitles:Strings.btnRetry,Strings.btnCancel)
    }
    
    func showFriendsViewController() {
        //perform the segue to show the friends view controller
        self.performSegue(withIdentifier: "showFriends", sender: self)
    }
    
    @IBAction func cancelToRootViewController(segue:UIStoryboardSegue) {
        //unwind segue so user can return here.
        //we don't do anything
    }
    
    //MARK: - Localizable Strings for our ViewController
    fileprivate struct Strings {
        static let missingPermissionsTitle = NSLocalizedString("You didn't grant us the friends permissions", comment: "This is the alert title shown to the user when he does not provide all asked permissions for his Facebook account")
        static let missingPermissionsMessage = NSLocalizedString("We need this permission to show you your friends!\nPlease allow us to get the permission, else we won't be able to continue", comment: "This is the alert message shown to the user when he does not provide all asked permissions for his Facebook account")
        static let btnRetry = NSLocalizedString("Get Permissions",comment: "Get missing permissions button title")
        static let btnCancel = NSLocalizedString("Cancel",comment: "Cancel button title")
        static let btnOK = NSLocalizedString("OK",comment: "OK button title")
        
        
        static let errorPermissionsTitle = NSLocalizedString("Something went wrong", comment: "This is the alert title shown to the user if an error happens during the FB Login process")
        static let errorPermissionsMessage = NSLocalizedString("An Error occured during the login\nError:%@\n\nPlease try again", comment: "This is the alert message shown to the user if an error happens during the FB Login process")
    }
    
}

