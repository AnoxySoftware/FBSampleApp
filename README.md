# FBSampleApp

[![Platform](https://img.shields.io/badge/Platform-iOS-blue.svg)](http://developer.apple.com/iOS)&nbsp;

FBSampleApp is a **UNIVERSAL** coding sample `Swift 3` iOS Application
The application supports rotation 

> The application uses Facebook SDK to allow the user to log in, then fetches the user's friends

  - Uses `AutoLayout` for the entire UI
  - Uses custom categories for extra functionality on UI Elements
  - Uses `Cocoapods` for FB SDK and third party libraries
  - Has `Unit Tests`

### Tech

Explanation of the application design
```
 - Uses an extension for UIColor and UIFont to provide global app colors & fonts
 - Uses a LoadingView while loading data, where elements are been added all in code, using Autolayout constraints (Visual Format Language and NSLayoutConstraints)
 - Uses a bash script to automatically increment the build number when we create an AdHoc or Release Build 
 - Uses Size Classes (in the LaunchScreen), so the size of the logo is adjusted according to the device (larger on iPad, smaller on iPhone)
 - Uses a custom Font Family (showing font embedding)
 - Uses FB Graph API to get users taggable_friends as graph v2 prohibits apps to get user's friends
 - Comprehensive Unit Tests that test downloading data from FB, parsing it, trying parsing wrong data, trying to get FB data without a valid token, etc
```

### Installation

The application can be downloaded and compiled using Xcode 8.2 or newer as it uses Swift 3 (older versions not supported)

&copy; 2017 Lefteris Haritou
