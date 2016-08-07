//
//  AppDelegate.swift
//  DebuggerZ80VirtualMachine
//
//  Created by Jose Luis Fernandez-Mayoralas on 31/12/15.
//  Copyright © 2015 lomocorp. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    var mainViewController: MainViewController!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        mainViewController = MainViewController(nibName: "MainViewController", bundle: nil)
        
        window.contentView!.addSubview(mainViewController.view)
        mainViewController.view.frame = (window.contentView! as NSView).bounds
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

