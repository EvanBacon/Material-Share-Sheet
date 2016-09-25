//
//  UIVIewControllerEx.swift
//  Share
//
//  Created by Evan Bacon on 05/01/16.
//  Copyright © 2016 brix. All rights reserved.
//

import UIKit

extension UIViewController {
    var orientation: UIInterfaceOrientation {
        get {
            return UIApplication.shared.statusBarOrientation
        }
        set {
            let orientationNum: NSNumber = NSNumber(value: orientation.rawValue as Int)
            UIDevice.current.setValue(orientationNum, forKey: "orientation")
        }
    }

    var isLandscape: Bool {
        return UIInterfaceOrientationIsLandscape(orientation)
    }
}
