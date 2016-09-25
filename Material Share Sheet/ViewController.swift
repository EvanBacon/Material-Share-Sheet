//
//  ViewController.swift
//  Material Share Sheet
//
//  Created by Evan Bacon on 9/24/16.
//  Copyright © 2016 Brix. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBAction func youShare(_ sender: UIButton) {
        /// Initalize
        let 🗣 = ShareSheetView(
            text: "Super Future",
            url: "http://harambesticker.com/",
            image: nil
        )
        
        /// Custom Parameters
        🗣.otherButtonTitle = "Other"
        🗣.cancelButtonTitle = "Dismiss"
        🗣.copyLinkButtonTitle = "Copy"
        🗣.copyFinishedMessage = "Copied!"
        🗣.animationDuration = 0.2
        
        /// Set Contents
        🗣.buttonList = [
            .other,
            .copyLink,
            .facebook,
            .twitter,
            .custom(
                title: "test",
                icon: nil,
                onTap: {
                    🗣.dismiss()
                }
            ),
        ]
        
        /// Finally
        🗣.show()
    }
}

/// Hint: (You can do emojis with: ⌘ ⌃ ␣ (CMD + CTRL + SPACE))
