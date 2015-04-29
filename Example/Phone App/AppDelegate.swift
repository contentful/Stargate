//
//  AppDelegate.swift
//  StargateExample
//
//  Created by Boris Bügling on 28/04/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import Stargate
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let stargate = Abydos(applicationGroupIdentifier: "group.com.contentful.Stargate")
    var window: UIWindow?

    func applicationDidFinishLaunching(application: UIApplication) {
        stargate.tunnel()

        // FIXME: Should be moved into tunnel() eventually
        UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler() {}
    }
}
