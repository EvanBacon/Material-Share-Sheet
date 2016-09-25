//
//  UIViewEx.swift
//  Share
//
//  Created by Evan Bacon on 05/01/16.
//  Copyright © 2016 brix. All rights reserved.
//

import UIKit


extension UIView {
    
    func findView<T>() -> T? {
        for view in self.subviews {
            if view is T {
                return view as? T
            }
        }
        return nil
    }
    
    
    var top : CGFloat{
        get{
            return self.frame.origin.y
        }
        set{
            var frame       = self.frame
            frame.origin.y  = newValue
            self.frame      = frame
        }
    }
    var bottom : CGFloat{
        get{
            return frame.origin.y + frame.size.height
        }
        set{
            var frame       = self.frame
            frame.origin.y  = newValue - self.frame.size.height
            self.frame      = frame
        }
    }
    var right : CGFloat{
        get{
            return self.frame.origin.x + self.frame.size.width
        }
        set{
            var frame       = self.frame
            frame.origin.x  = newValue - self.frame.size.width
            self.frame      = frame
        }
    }
    var left : CGFloat{
        get{
            return self.frame.origin.x
        }
        set{
            var frame       = self.frame
            frame.origin.x  = newValue
            self.frame      = frame
        }
    }
    var width : CGFloat{
        get{
            return self.frame.size.width
        }
        set{
            var frame         = self.frame
            frame.size.width  = newValue
            self.frame        = frame
        }
    }
    var height : CGFloat{
        get{
            return self.frame.size.height
        }
        set{
            var frame          = self.frame
            frame.size.height  = newValue
            self.frame         = frame
        }
    }
}
