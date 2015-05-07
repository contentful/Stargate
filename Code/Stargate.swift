//
//  Stargate.swift
//  Stargate
//
//  Created by Boris Bügling on 28/04/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import MultipeerConnectivity
import PeerKit

/// Closure for debug messages
public typealias DebugHandler = (message: String) -> Void

/// Base class, public because a public class can't inherit from an internal one.
public class Base {
    private var applicationGroupIdentifier: String = ""
    var pingIdentifier = "274EAEF1-A178-47FE-81F4-96E87C242456"
    var pingPayload = "ping"
    var sanitizedIdentifier: String {
        return applicationGroupIdentifier.stringByReplacingOccurrencesOfString(".", withString: "", options: NSStringCompareOptions.allZeros, range: nil).substringToIndex(advance(applicationGroupIdentifier.startIndex, 15))
    }

    init(applicationGroupIdentifier: String) {
        self.applicationGroupIdentifier = applicationGroupIdentifier
    }

    func listenForMessage(#identifier: String, _ listener: ((AnyObject!) -> Void)) {
        fatalError("listenForMessage() needs to be overidden in subclasses.")
    }

    func passMessage(message: NSCoding, identifier: String) {
        fatalError("passMessageObject() needs to be overidden in subclasses.")
    }

    func sendMultipeerMessage(message: AnyObject, identifier: String) {
        let allPeers = PeerKit.session?.connectedPeers as? [MCPeerID]
        PeerKit.sendEvent(identifier, object: message, toPeers: allPeers)
    }

    func stopListeningForMessage(#identifier: String) {
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

    /// Create an initialized Stargate endpoint
    public override init(applicationGroupIdentifier: String) {
        super.init(applicationGroupIdentifier: applicationGroupIdentifier)

        PeerKit.transceive(sanitizedIdentifier)
        sendMultipeerMessage(pingPayload, identifier: pingIdentifier)

        wormhole = MMWormhole(applicationGroupIdentifier: applicationGroupIdentifier, optionalDirectory: "stargate")
        wormhole.passMessageObject(pingPayload, identifier: pingIdentifier)
    }

    /// The closure argument will be called for all connecting peers and messages passing through.
    public func debug(callback: DebugHandler) {
        PeerKit.onConnect = { (me, you) -> Void in callback(message: "connect: \(me) <=> \(you)") }
        self.callback = callback
    }

    /// Set up the tunneling from Mac => Watch
    public func tunnel() {
        PeerKit.transceive(sanitizedIdentifier)
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

    /// Set up tunneling from Watch => Mac for the given identifier
    public func tunnelReplies(#identifier: String) {
        wormhole.listenForMessageWithIdentifier(identifier) { (message) -> Void in
            if let message: AnyObject = message {
                if let callback = self.callback {
                    callback(message: "Received message from watch: \(message) for \(identifier)")
                }

                self.sendMultipeerMessage(message, identifier: identifier)
            }
        }
    }
}

/// Stargate endpoint to be used on the ᴡᴀᴛᴄʜ
public class Atlantis : Base {
    var wormhole: MMWormhole!

    /// Create an initialized Stargate endpoint
    public override init(applicationGroupIdentifier: String) {
        super.init(applicationGroupIdentifier: applicationGroupIdentifier)

        wormhole = MMWormhole(applicationGroupIdentifier: applicationGroupIdentifier, optionalDirectory: "stargate")
        passMessage(pingPayload, identifier: pingIdentifier)
    }

    /// Listen for messages with identifier, closure will be called for each.
    public override func listenForMessage(#identifier: String, _ listener: ((AnyObject!) -> Void)) {
        wormhole.listenForMessageWithIdentifier(identifier, listener: listener)

        WKInterfaceController.openParentApplication([NSObject : AnyObject](), reply: nil)
    }

    /// Pass a message with the given identifier
    public override func passMessage(message: NSCoding, identifier: String) {
        wormhole.passMessageObject(message, identifier: identifier)

        WKInterfaceController.openParentApplication([NSObject : AnyObject](), reply: nil)
    }

    /// Stop listening for messages with the given identifier
    public override func stopListeningForMessage(#identifier: String) {
        wormhole.stopListeningForMessageWithIdentifier(identifier)
    }
}

#endif

/// Stargate endpoint to be used on the Mac
public class Earth : Base {
    /// Create an initialized Stargate endpoint
    public override init(applicationGroupIdentifier: String) {
        super.init(applicationGroupIdentifier: applicationGroupIdentifier)

        PeerKit.transceive(sanitizedIdentifier)
        passMessage(pingPayload, identifier: pingIdentifier)
    }

    /// Listen for messages with identifier, closure will be called for each.
    public override func listenForMessage(#identifier: String, _ listener: ((AnyObject!) -> Void)) {
        PeerKit.eventBlocks[identifier] = { (peerID, object) -> Void in
            listener(object)
        }
    }

    /// Pass a message with the given identifier
    public override func passMessage(message: NSCoding, identifier: String) {
        sendMultipeerMessage(message, identifier: identifier)
    }

    /// Stop listening for messages with the given identifier
    public override func stopListeningForMessage(#identifier: String) {
        PeerKit.stopTransceiving()
    }
}
