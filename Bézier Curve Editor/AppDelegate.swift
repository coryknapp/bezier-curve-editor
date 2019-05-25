//
//  AppDelegate.swift
//  Bézier Curve Editor
//
//  Created by Cory Knapp on 5/21/19.
//  Copyright © 2019 Cory Knapp. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        window.acceptsMouseMovedEvents = true
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

