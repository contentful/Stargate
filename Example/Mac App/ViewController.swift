//
//  ViewController.swift
//  Stargate
//
//  Created by Boris Bügling on 28/04/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import Cocoa
import Stargate

class ViewController: NSViewController, NSTextViewDelegate {
    let stargate = Earth(applicationGroupIdentifier: "group.com.contentful.Stargate")

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "fileOpened:", name: AppDelegate.FileOpenedNotification, object: nil)
    }

    func fileOpened(note: NSNotification) {
        if let userInfo = note.userInfo, filename = userInfo[AppDelegate.FileToOpen] as? String {
            if let data = NSData(contentsOfFile: filename) {
                stargate.passMessage(data, identifier: "stargate.file")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        stargate.listenForMessage(identifier: "stargate2") { (object) -> Void in
            println("Received message on Mac: \(object)")
        }
    }

    // MARK: NSTextViewDelegate

    func textDidChange(notification: NSNotification) {
        if let textView = notification.object as? NSTextView, text = textView.string {
            stargate.passMessage(text, identifier: "stargate")
        }
    }
}
