//
//  InterfaceController.swift
//  StargateExample WatchKit Extension
//
//  Created by Boris Bügling on 28/04/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import Foundation
import Stargate
import WatchKit

class InterfaceController: WKInterfaceController {
    @IBOutlet weak var image: WKInterfaceImage!
    @IBOutlet weak var label: WKInterfaceLabel!

    let stargate = Atlantis(applicationGroupIdentifier: "group.com.contentful.Stargate")

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }

    override func willActivate() {
        super.willActivate()

        stargate.listenForMessage(identifier:"stargate") { (object) -> Void in
            self.label.setText(object as? String)
        }
    }

    override func didDeactivate() {
        super.didDeactivate()

        stargate.stopListeningForMessage(identifier:"stargate")
    }
}
