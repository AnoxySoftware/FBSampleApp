//
//  LoadingView.swift
//  SampleSwiftApp
//
//  Created by Eleftherios Charitou on 10/01/17.
//  Copyright © 2017 Anoxy Software. All rights reserved.
//

import UIKit

//creates a custom overlay view, used as a loading animation
public class LoadingOverlay {
    
    var overlayView : UIView!
    var activityIndicator : UIActivityIndicatorView!
    var titleLabel : UILabel!
    
    static let shared = LoadingOverlay()
    
    init(){
        self.overlayView = UIView()
        self.activityIndicator = UIActivityIndicatorView()
        self.titleLabel = UILabel()
        
        overlayView.frame = CGRect(x: 0, y: 0, width: 300, height: 140)
        overlayView.backgroundColor = UIColor.customRedColor()
        overlayView.clipsToBounds = true
        overlayView.layer.cornerRadius = 5
        overlayView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        overlayView.layer.zPosition = 10000

        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(activityIndicator)
        
        //center the activity indicator in the overlay view (centerY is a bit to the top)
        NSLayoutConstraint(item:activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: overlayView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item:activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: overlayView, attribute: .centerY, multiplier: 1, constant: -10).isActive = true
        
        //set the titlelabel attributes
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.appFont()
        titleLabel.numberOfLines = 0
        titleLabel.text = Strings.loadingTitle
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(titleLabel)
        
        //use VFL to adjust the label (pinned right & left horizontally with the default margin)
        let horizontalConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-|", options:[] , metrics:nil, views:Dictionary(dictionaryLiteral:("label",titleLabel!)))
        //vertically pinned to the bottom of the view with 10 pixels margin
        let verticalConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:[label]-10-|", options:[] , metrics:nil, views:Dictionary(dictionaryLiteral:("label",titleLabel!)))
        overlayView.addConstraints(verticalConstraint)
        overlayView.addConstraints(horizontalConstraint)
    }
    
    public func showOverlay(view: UIView) {
        overlayView.center = view.center
        view.addSubview(overlayView)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.overlayView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion:{ _ in
            self.activityIndicator.startAnimating()
        })
        
    }
    
    public func hideOverlayView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.overlayView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }, completion:{ _ in
            self.activityIndicator.stopAnimating()
            self.overlayView.removeFromSuperview()
        })
    }
    
    struct Strings {
        static let loadingTitle = NSLocalizedString("Please Wait\nLoading Data...",comment: "Loading message shown while fetching Data")
    }
}
