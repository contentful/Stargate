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
    @IBOutlet weak var button: WKInterfaceButton!
    @IBOutlet weak var image: WKInterfaceImage!

    let stargate = Atlantis(applicationGroupIdentifier: "group.com.contentful.Stargate")

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }

    @IBAction func buttonTapped() {
        stargate.passMessage("buttonTapped", identifier:"stargate2")
    }

    override func willActivate() {
        super.willActivate()

        stargate.listenForMessage(identifier:"stargate") { (object) -> Void in
            self.button.setTitle(object as? String)
        }

        stargate.listenForMessage(identifier:"stargate.file") { (object) -> Void in
            if let data = object as? NSData {
                let image = UIImage(data: data)
                self.image.setImage(image)
            }
        }
    }

    override func didDeactivate() {
        super.didDeactivate()

        stargate.stopListeningForMessage(identifier:"stargate")
    }
}
