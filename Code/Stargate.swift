//
//  Stargate.swift
//  Stargate
//
//  Created by Boris Bügling on 28/04/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import MultipeerConnectivity
import PeerKit

public typealias DebugHandler = (message: String) -> Void

public class Base {
    private var applicationGroupIdentifier: String = ""
    var sanitizedIdentifier: String {
        return applicationGroupIdentifier.stringByReplacingOccurrencesOfString(".", withString: "", options: NSStringCompareOptions.allZeros, range: nil).substringToIndex(advance(applicationGroupIdentifier.startIndex, 15))
    }

    public init(applicationGroupIdentifier: String) {
        self.applicationGroupIdentifier = applicationGroupIdentifier
    }

    public func listenForMessage(#identifier: String, _ listener: ((AnyObject!) -> Void)) {
        fatalError("listenForMessage() needs to be overidden in subclasses.")
    }

    public func passMessage(message: NSCoding, identifier: String) {
        fatalError("passMessageObject() needs to be overidden in subclasses.")
    }

    public func stopListeningForMessage(#identifier: String) {
        fatalError("stopListeningForMessage() needs to be overidden in subclasses.")
    }
}

#if os(iOS)
import MMWormhole
import WatchKit
import UIKit

/// Stargate endpoint to be used on the phone
public class Abydos : Base {
    private var callback: DebugHandler?
    var wormhole: MMWormhole!

    public override init(applicationGroupIdentifier: String) {
        super.init(applicationGroupIdentifier: applicationGroupIdentifier)

        PeerKit.transceive(sanitizedIdentifier)

        wormhole = MMWormhole(applicationGroupIdentifier: applicationGroupIdentifier, optionalDirectory: "stargate")
    }

    public func debug(callback: DebugHandler) {
        PeerKit.onConnect = { (me, you) -> Void in callback(message: "connect: \(me) <=> \(you)") }
        self.callback = callback
    }

    public func tunnel() {
        PeerKit.onEvent = { (peerID, event, object) -> Void in
            if let object = object as? NSCoding {
                if let callback = self.callback {
                    callback(message: "Received message from Mac: \(object) for \(event)")
                }

                self.wormhole.passMessageObject(object, identifier: event)
            }
        }

        //UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler() {}
    }

    public func tunnelReplies(#identifier: String) {
        wormhole.listenForMessageWithIdentifier(identifier) { (message) -> Void in
            if let message: AnyObject = message {
                let allPeers = PeerKit.session?.connectedPeers as? [MCPeerID]
                PeerKit.sendEvent(identifier, object: message, toPeers: allPeers)
                if let callback = self.callback {
                    callback(message: "Received message from watch: \(message) for \(identifier)")
                }

            }
        }
    }
}

/// Stargate endpoint to be used on the ᴡᴀᴛᴄʜ
public class Atlantis : Base {
    var wormhole: MMWormhole!

    public override init(applicationGroupIdentifier: String) {
        super.init(applicationGroupIdentifier: applicationGroupIdentifier)

        wormhole = MMWormhole(applicationGroupIdentifier: applicationGroupIdentifier, optionalDirectory: "stargate")
    }

    public override func listenForMessage(#identifier: String, _ listener: ((AnyObject!) -> Void)) {
        wormhole.listenForMessageWithIdentifier(identifier, listener: listener)

        WKInterfaceController.openParentApplication([NSObject : AnyObject](), reply: nil)
    }

    public override func passMessage(message: NSCoding, identifier: String) {
        wormhole.passMessageObject(message, identifier: identifier)

        WKInterfaceController.openParentApplication([NSObject : AnyObject](), reply: nil)
    }

    public override func stopListeningForMessage(#identifier: String) {
        wormhole.stopListeningForMessageWithIdentifier(identifier)
    }
}

#endif

/// Stargate endpoint to be used on the Mac
public class Earth : Base {
    public override init(applicationGroupIdentifier: String) {
        super.init(applicationGroupIdentifier: applicationGroupIdentifier)

        PeerKit.transceive(sanitizedIdentifier)
    }

    public override func listenForMessage(#identifier: String, _ listener: ((AnyObject!) -> Void)) {
        PeerKit.eventBlocks[identifier] = { (peerID, object) -> Void in
            listener(object)
        }
    }

    public override func passMessage(message: NSCoding, identifier: String) {
        let allPeers = PeerKit.session?.connectedPeers as? [MCPeerID]
        PeerKit.sendEvent(identifier, object: message, toPeers: allPeers)
    }

    public override func stopListeningForMessage(#identifier: String) {
        PeerKit.stopTransceiving()
    }
}
