//
//  ShareView.swift
//  Share
//
//  Created by Evan Bacon on 05/01/16.
//  Copyright © 2016 brix. All rights reserved.
//

import Foundation
import UIKit
import Social



/*
 Example:
 
 *import Social
 
 let shareView = ShareView(
 text: "Harambe the zombie!",
 url: "http://harambesticker.com/",
 image: nil
 )
 
 shareView.otherButtonTitle = "Other"
 shareView.cancelButtonTitle = "Dismiss"
 shareView.copyLinkButtonTitle = "Copy"
 shareView.copyFinishedMessage = "Copied!"
 shareView.animationDuration = 0.2
 
 shareView.buttonList = [
 .other,
 .twitter,
 .copyLink,
 .facebook,
 .custom(
 title: "Never Forget",
 icon: nil,
 onTap: {
 shareView.dismiss()
 }
 ),
 ]
 
 shareView.show()
 
 */

/// Share Info Class
class ShareObject {
    let text:String!
    let url:String?
    let image:UIImage?
    
    init(text:String, url:String?, image:UIImage?) {
        self.text = text
        self.url = url
        self.image = image
    }
}

public enum ShareType {
    case twitter
    case facebook
    case copyLink
    case other
    case custom(title:String, icon:UIImage?, onTap:()->())
    
    func value() -> String {
        switch self {
        case .twitter  : return SLServiceTypeTwitter
        case .facebook : return SLServiceTypeFacebook
        case .copyLink : return "CopyLink"
        case .other : return "Other"
        case .custom : return "Custom"
        }
    }
    
    func imageName() -> String {
        switch self {
        case .twitter  : return "twitter"
        case .facebook : return "facebook"
        case .copyLink : return "link"
        case .other : return "other"
        default : return "max from google"
        }
    }
}

// type behaver
extension ShareSheetView {
    func buttonText(_ type: ShareType) -> String {
        switch type {
        case .twitter  : return "Twitter"
        case .facebook : return "Facebook"
        case .other : return otherButtonTitle
        case .copyLink : return copyLinkButtonTitle
        case let .custom(title, _, _): return title
        }
    }
    
    func buttonIcon(_ type: ShareType)-> UIImage? {
        switch type {
        case let .custom(_, icon, _): return icon
        default: return imageNamed(type.imageName())
        }
    }
    
    func typeBehave(_ type: ShareType) {
        switch type {
        case .twitter, .facebook, .other:
            self.openComposer(type) {
                self.dismiss()
            }
        case .copyLink:
            self.copyLink()
            self.dismiss()
        case let .custom(_, _, onTap):
            onTap()
        }
    }
    
    func addButton(_ type:ShareType) {
        addButton(buttonText(type), icon: buttonIcon(type)) {
            self.typeBehave(type)
        }
    }
}

open class ShareSheetView : UIViewController, UIGestureRecognizerDelegate {
    
    open var buttonList:[ShareType] = []
    open var otherButtonTitle = "Other"
    open var cancelButtonTitle = "Cancel"
    open var copyFinishedMessage = "Copy Succeed."
    open var copyFaildedMessage = "Copy Failed."
    open var copyLinkButtonTitle = "Copy Link"
    open var animationDuration: TimeInterval = 0.2
    
    fileprivate let defaultFont = UIFont(name: "Avenir-Next", size: 13)!
    fileprivate var maxSize:CGRect!
    fileprivate let buttonHeight:CGFloat = 60// TODO: あとで可変になるかも
    fileprivate let cancelButtonHeight:CGFloat = 52// TODO: あとで可変になるかも
    fileprivate let borderColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
    fileprivate let cancelButtonColor = UIColor(red: 0.972549, green: 0.972549, blue: 0.972549, alpha: 1)
    fileprivate let cancelButtonTextColor = UIColor(red: 184/255, green: 184/255, blue: 184/255, alpha: 1)
    fileprivate let iconMarginLeft:CGFloat = 9
    fileprivate var backgroundAlpha:CGFloat = 0.8
    fileprivate let copiedMessageViewHeight:CGFloat = 50
    fileprivate let copiedMessageLabelMarginLeft:CGFloat = 12
    fileprivate let copiedMessageLabelTextColor = UIColor.white
    fileprivate let copiedMessageViewColor = UIColor(white: 0.275, alpha: 1)
    fileprivate let copiedMessageFont = UIFont(name: "Avenir-Next", size: 12)!
    fileprivate var buttonsHeight:CGFloat {
        get { return maxSize.height - buttons.last!.top }
    }
    
    fileprivate var buttons:[UIButton] = []
    fileprivate var labels:[UILabel] = []
    fileprivate var icons:[UIImageView] = []
    fileprivate var borders:[UIView?] = []
    fileprivate var buttonActions:[()->()] = []
    
    var shareObject: ShareObject!
    let backgroundSheet = UIView()
    let buttonSheet = UIView()
    let copiedMessageView = UIView()
    let copiedMessageLabel = UILabel()
    
    public init(text:String, url:String?, image:UIImage?) {
        self.shareObject = ShareObject(text: text, url: url, image: image)
        super.init(nibName: nil, bundle: nil)
        self.setup()
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setup() {
        backgroundSheet.backgroundColor = UIColor.black.withAlphaComponent(backgroundAlpha)
        copiedMessageView.backgroundColor = copiedMessageViewColor
        copiedMessageView.isHidden = true
        copiedMessageLabel.font = copiedMessageFont
        copiedMessageLabel.textColor = copiedMessageLabelTextColor
        copiedMessageView.addSubview(copiedMessageLabel)
        
        self.view.addSubview(backgroundSheet)
        self.view.addSubview(buttonSheet)
        
        let tapGesture = UITapGestureRecognizer(target:self, action:#selector(ShareSheetView.didTapBackgroundSheet))
        tapGesture.delegate = self
        buttonSheet.isUserInteractionEnabled = true
        buttonSheet.addGestureRecognizer(tapGesture)
    }
    
    open func show() {
        viewWillShow()
        showAnimation()
    }
    
    open func dismiss() {
        disapperAnimation()
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func viewWillShow() {
        
        if buttonList.count == 0 {
            buttonList = [.other, .copyLink, .facebook, .twitter]
        }
        
        addCancelButton {
            self.dismiss()
        }
        
        for buttonType in buttonList {
            addButton(buttonType)
        }
        
        layoutViews()
    }
    
    func onTapButon(_ btn:UIButton!) {
        buttonActions[btn.tag]()
    }
    
    func didTapBackgroundSheet() {
        dismiss()
    }
}

// add button
extension ShareSheetView {
    fileprivate func addCancelButton(_ onTapFunc:@escaping ()->()) {
        addButton(
            cancelButtonTitle,
            icon: nil,
            height: cancelButtonHeight,
            bgColor: cancelButtonColor,
            textColor: cancelButtonTextColor,
            borderColor: nil,
            onTapFunc: onTapFunc
        )
    }
    fileprivate func addButton(_ text: String, icon: UIImage?, onTapFunc: @escaping ()->()) {
        addButton(
            text,
            icon: icon,
            height: buttonHeight,
            bgColor: UIColor.white,
            textColor: UIColor.black,
            borderColor: borderColor,
            onTapFunc: onTapFunc
        )
    }
    fileprivate func addButton(_ text:String, icon: UIImage?, height: CGFloat, bgColor: UIColor, textColor: UIColor, borderColor: UIColor?, onTapFunc: @escaping ()->()) {
        let btn = UIButton()
        let iconView = UIImageView(image: icon)
        let label = UILabel()
        
        btn.tag = buttons.count
        buttons.append(btn)
        icons.append(iconView)
        labels.append(label)
        buttonActions.append(onTapFunc)
        
        iconView.contentMode = UIViewContentMode.center
        label.text = text
        label.textAlignment = NSTextAlignment.center
        label.font = self.defaultFont
        label.textColor = textColor
        btn.backgroundColor = bgColor
        
        var border: UIView? = nil
        if borderColor != nil {
            if btn.tag >= 2 {
                border = UIView()
                border!.backgroundColor = borderColor!
                buttonSheet.addSubview(border!)
            }
        }
        btn.addTarget(self, action: #selector(ShareSheetView.onTapButon(_:)), for: .touchUpInside)
        borders.append(border)
        
        btn.addSubview(label)
        btn.addSubview(iconView)
        buttonSheet.addSubview(btn)
    }
}

// layout
extension ShareSheetView {
    fileprivate func imageNamed(_ name:String)->UIImage? {
        return UIImage(named: name, in: Bundle(for: ShareSheetView.self), compatibleWith: nil)
    }
    
    fileprivate func showAnimation() {
        if UIApplication.shared.delegate == nil{
            print("window is not found.")
            return
        }
        buttonSheet.top = buttonSheet.top + buttonsHeight
        backgroundSheet.alpha = 0
        
        let window:UIWindow = UIApplication.shared.delegate!.window!!
        window.addSubview(copiedMessageView)
        window.addSubview(self.view)
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.backgroundSheet.alpha = 1
            self.buttonSheet.top = self.buttonSheet.top - self.buttonsHeight
            },
                       completion: { _ in
        })
    }
    
    fileprivate func disapperAnimation() {
        UIView.animate(withDuration: animationDuration, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.backgroundSheet.alpha = 0
            self.buttonSheet.top = self.buttonSheet.top + self.buttonsHeight
            },
                       completion: { _ in
                        self.view.removeFromSuperview()
                        if self.copiedMessageView.isHidden == true {
                            self.copiedMessageView.removeFromSuperview()
                        }
                        else {
                            Timer.schedule(repeatInterval: 1) { timer in
                                UIView.animate(withDuration: self.animationDuration, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
                                    self.copiedMessageView.alpha = 0
                                    },
                                               completion: { _ in
                                                self.copiedMessageView.removeFromSuperview()
                                })
                            }
                        }
            }
        )
    }
    
    
    fileprivate func layoutViews() {
        maxSize = UIScreen.main.bounds
        buttonSheet.frame = maxSize
        backgroundSheet.frame = maxSize
        
        copiedMessageView.frame = CGRect(
            x: 0,
            y: maxSize.height - copiedMessageViewHeight,
            width: maxSize.width,
            height: copiedMessageViewHeight
        )
        
        copiedMessageLabel.frame = CGRect(
            x: copiedMessageLabelMarginLeft, y: 0,
            width: maxSize.width, height: copiedMessageViewHeight
        )
        
        for btn in buttons {
            let iconView = icons[btn.tag]
            let label = labels[btn.tag]
            var preBtn:UIButton? = nil
            if btn.tag != 0 {
                preBtn = buttons[(btn.tag - 1)]
            }
            
            var height = buttonHeight
            if btn.tag == 0 {
                height = cancelButtonHeight
            }
            
            iconView.frame = CGRect(x: iconMarginLeft, y: 0, width: height, height: height)
            label.frame = CGRect(x: 0, y: 0, width: maxSize.width, height: height)
            btn.frame = CGRect(x: 0, y: 0, width: maxSize.width, height: height)
            
            if preBtn == nil {
                btn.bottom = maxSize.height
            }
            else {
                btn.bottom = preBtn!.top
            }
            
            if borders[btn.tag] != nil {
                let brdr:UIView = borders[btn.tag]!
                brdr.frame = CGRect(x: 0, y: 0, width: maxSize.width, height: 1)
                brdr.bottom = preBtn!.top//borderがあるならpreBtnはある
                btn.bottom = brdr.top
            }
        }
    }
}

extension ShareSheetView {
    
    public func copyLink() {
        UIPasteboard.general.string = shareObject.url
        
        if (UIPasteboard.general.string == shareObject.url) {
            self.copiedMessageLabel.text = self.copyFinishedMessage
        } else {
            self.copiedMessageLabel.text = self.copyFaildedMessage
        }
        
        self.copiedMessageView.isHidden = false
    }
    
    public func openComposer(_ type: ShareType, completion:(()->())?) {
        switch type {
        case .other:
            openActivityView(completion)
            
        default:
            //if SLComposeViewController.isAvailableForServiceType(type.value()) {
            let composeVC = SLComposeViewController(forServiceType: type.value())
            composeVC?.setInitialText(shareObject.text)
            if shareObject.url != nil {
                if let urlObj = URL(string: shareObject.url!) {
                    composeVC?.add(urlObj)
                }
            }
            if shareObject.image != nil {
                composeVC?.add(shareObject.image!)
            }
            
            if completion != nil {
                composeVC?.completionHandler = { (result: SLComposeViewControllerResult) -> () in
                    switch (result) {
                    case SLComposeViewControllerResult.done:
                        completion!()
                    case SLComposeViewControllerResult.cancelled:
                        completion!()
                    }
                }
            }
            self.present(composeVC!, animated: true, completion: nil)
        }
    }
    
    
    fileprivate func openActivityView(_ completion:(()->())?) {
        var items: [AnyObject] = []
        
        items.append(shareObject.text as AnyObject)
        
        if shareObject.url != nil {
            if let urlObj = URL(string: shareObject.url!) {
                items.append(urlObj as AnyObject)
            }
        }
        
        if shareObject.image != nil {
            items.append(shareObject.image!)
        }
        
        let activityVC = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        activityVC.completionWithItemsHandler = { activityType, isCompleted, returnedItems, error in
            if (isCompleted) {
                completion?()
            }
        }
        self.present(activityVC, animated: true, completion: nil)
    }
}

