//
//  DataModels.swift
//  FBSampleApp
//
//  Created by Eleftherios Charitou on 12/01/17.
//  Copyright © 2017 Anoxy Software. All rights reserved.
//

import Foundation

///a Data Model of the FBUser Data we are expecting
///Some fields are not optional and if data are missing, we will assing an empty string to them
struct FBUser {
    let id: String
    let about: String
    let birthday: String
    let profilePictureURLString: String?
    let email: String?
    let firstName: String?
    let lastName: String?
    let name: String
    let relationshipStatus: String
    let location: Location?
}

struct Coordinate {
    let latitude: Double
    let longitude: Double
}

extension Coordinate: CustomStringConvertible {
    var description: String {
        return "\(latitude),\(longitude)"
    }
}

//Everything here is an optional, we populate whatever we can
struct Location {
    let city: String?
    let country: String?
    let state: String?
    let street: String?
    let zip: String?
    let coordinate: Coordinate?
}

extension FBUser {
    init?(JSON: [String : Any]) {
        
        //if we don't get a name, or id we don't popuplate the object
        //it's a required parameter of our DataModel
        guard let name = JSON["name"] as? String,
            let id = JSON["id"] as? String else {
            return nil
        }
        
        self.name = name
        self.id = id
        
        //populate the rest of the user model
        //fields referrence: https://developers.facebook.com/docs/graph-api/reference/user
        
        //if we don't have a value we assign an empty string to our object
        self.firstName = JSON["first_name"] as? String
        self.lastName = JSON["last_name"] as? String
        self.about = JSON["about"] as? String ?? ""
        self.birthday = JSON["birthday"] as? String ?? ""
        self.email = JSON["email"] as? String
        self.relationshipStatus = JSON["relationship_status"] as? String ?? ""
        
        //get the user's profile picture....
        if let picture = JSON["picture"] as? [String: Any],
            let data = picture["data"] as? [String: Any],
            let url = data["url"] as? String {
            self.profilePictureURLString = url
        }
        else {
            self.profilePictureURLString = nil
        }
        
        //get the user's location if we have the data for it
        if let locationDict = JSON["location"] as? [String: Any] {
            self.location = Location(JSON: locationDict)
        }
        else {
            self.location = nil
        }
        
    }
}

extension Location {
    init?(JSON: [String : Any]) {
        
        if let latitude = JSON["latitude"] as? Double, let longitude = JSON["longitude"] as? Double {
            coordinate = Coordinate(latitude: latitude, longitude: longitude)
        } else {
            coordinate = nil
        }
        
        self.city = JSON["city"] as? String
        self.country = JSON["country"] as? String
        self.state = JSON["state"] as? String
        self.street = JSON["street"] as? String
        self.zip = JSON["zip"] as? String
    }
}
