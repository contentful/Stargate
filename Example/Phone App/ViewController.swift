//
//  ViewController.swift
//  StargateExample
//
//  Created by Boris Bügling on 28/04/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import Stargate
import UIKit

class ViewController: UIViewController {
    let stargate = Abydos(applicationGroupIdentifier: "group.com.contentful.Stargate")
    @IBOutlet weak var textView: UITextView!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidFinishLaunching", name: UIApplicationDidFinishLaunchingNotification, object: nil)
    }

    func applicationDidFinishLaunching() {
        stargate.debug { (message) -> Void in
            var text = self.textView.text ?? ""
            text += "\n"
            text += message
            self.textView.text = text
        }

        stargate.tunnel()
        stargate.tunnelReplies(identifier: "stargate2")

        // FIXME: Should be moved into tunnel() eventually
        UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler() {}
    }    
}
