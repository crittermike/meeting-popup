//
//  AppDelegate.swift
//  Meeting Popup
//
//  Created by Mike Crittenden on 10/9/19.
//  Copyright © 2019 Mike Crittenden. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var window: NSWindow!
    let eventService = EventService()
    var statusBarItem: NSStatusItem!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Set up the menu bar icon and menu.
        let statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)
        statusBarItem.button?.image = NSImage(named:NSImage.Name("StatusBarImage"))
        let statusBarMenu = NSMenu(title: "Meeting Popup")
        statusBarItem.menu = statusBarMenu
        statusBarMenu.addItem(
            withTitle: "Show Window",
            action: #selector(AppDelegate.openWindow),
            keyEquivalent: "")
        statusBarMenu.addItem(
            withTitle: "Exit",
            action: #selector(AppDelegate.exitApplication),
            keyEquivalent: "")
        
        // Create the window and set the content view.
        let contentView = ContentView()
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1000, height: 750),
            styleMask: [.titled, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.makeKeyAndOrderFront(nil)
        NSApp.hide(nil)
    }
    
    @objc func exitApplication() {
        print("Exiting!")
        NSApplication.shared.terminate(self)
    }
    
    @objc public func openWindow() {
        NSApp.unhideWithoutActivation()
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    private func windowShouldClose(_ sender: Any) -> Bool {
        print("Closing window")
        NSApp.hide(nil)
        return false
    }
}

