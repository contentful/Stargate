//
//  AppDelegate.swift
//  Stargate
//
//  Created by Boris Bügling on 28/04/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    class var FileOpenedNotification: String { return "FileOpenedNotification" }
    class var FileToOpen: String { return "FileToOpen" }

    func application(sender: NSApplication, openFile filename: String) -> Bool {
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: self.dynamicType.FileOpenedNotification, object: self, userInfo: [self.dynamicType.FileToOpen: filename]))
        return true
    }
}
