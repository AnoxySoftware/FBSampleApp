//
//  Custom.swift
//  SampleSwiftApp
//
//  Created by Eleftherios Charitou on 09/01/17.
//  Copyright © 2017 Anoxy Software. All rights reserved.
//

import UIKit

extension UIColor {
    
    ///Convenience initializer with hex values
    ///Taken from http://stackoverflow.com/a/24263296/312312
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(hex:Int) {
        self.init(red:(hex >> 16) & 0xff, green:(hex >> 8) & 0xff, blue:hex & 0xff)
    }
    
    class func customBlueColor() -> UIColor {
        return UIColor(hex: 0x1BA3EA)
    }
    
    class func customRedColor() -> UIColor {
        return UIColor(hex: 0xD32F2F)
    }
    
    class func customDarkGray() -> UIColor {
        return UIColor(hex: 0x353535)
    }
    
    class func customLightGray() -> UIColor {
        return UIColor(hex: 0x888888)
    }
    
}

extension UIFont {
    class func appFont() -> UIFont {
        return UIFont(name: "PFStudioHeavy-Regular", size: 14.0)!
    }
    class func smallAppFont() -> UIFont {
        return UIFont(name: "PFStudioHeavy-Regular", size: 11.0)!
    }
}
