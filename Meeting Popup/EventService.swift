//
//  EventService.swift
//  Meeting Popup
//
//  Created by Mike Crittenden on 10/10/19.
//  Copyright © 2019 Mike Crittenden. All rights reserved.
//

import Foundation
import Cocoa
import EventKit

class EventService: ObservableObject {
    @Published var type: String = ""
    @Published var title: String = ""
    @Published var joinUrl: String = ""
    let eventStore = EKEventStore()
    
    init() {
        self.title = "Loading..."
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch (status) {
        case EKAuthorizationStatus.notDetermined:
            // This happens on first run.
            requestAccess()
        case EKAuthorizationStatus.authorized:
            // Access granted, so let's kick things off.
            startWatchingNextEvent()
        default:
            self.title = "Calendar access denied!"
        }
    }
    
    func requestAccess() {
        eventStore.requestAccess(to: .event, completion: {
            (accessGranted: Bool, error: Error?) in
            
            if accessGranted == true {
                DispatchQueue.main.async(execute: {
                    self.startWatchingNextEvent()
                })
            } else {
                DispatchQueue.main.async(execute: {
                    self.title = "Calendar access denied!"
                })
            }
        })
    }
    
    func startWatchingNextEvent() {
        // Every time the minute changes, re-check to see if there's an event about to start.
        let cal = NSCalendar.current
        var comps = cal.dateComponents([.era, .year, .month, .day, .hour, .minute], from: Date())
        comps.minute = comps.minute! + 1

        let nextMinute = cal.date(from: comps)
        let timer = Timer(fire: nextMinute!, interval: 60, repeats: true, block: { timer in
            let nextEvent = self.fetchNextEvent()
            self.title = self.getTitle(event: nextEvent)
            self.joinUrl = self.getJoinUrl(event: nextEvent)
            self.type = self.getType(joinUrl: self.joinUrl)
            
            // Show the app window.
            print("Showing app window...")
            NSApp.unhideWithoutActivation()
            NSApp.activate(ignoringOtherApps: true)
        })

        RunLoop.current.add(timer, forMode: .default)
    }
    
    func fetchNextEvent() -> EKEvent {
        var nextEvent = EKEvent()
        
        let start = Date()
        let end = Date()
        
        let predicate = self.eventStore.predicateForEvents(withStart: start, end: end, calendars: nil)
        let events = self.eventStore.events(matching: predicate)
        for event in events {
            nextEvent = event
            break
        }
        return nextEvent
    }
    
    func getTitle(event: EKEvent) -> String {
        return event.title
    }
    
    func getJoinUrl(event: EKEvent) -> String {
        var joinUrl = ""
        
        // Remove HTML from the event notes.
        let input = (event.notes ?? "").replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression, range: nil)
        
        // Search for links in the event notes.
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
        
        // Loop through the links to try to find a video call link.
        for match in matches {
            guard let range = Range(match.range, in: input) else { continue }
            let testUrl = String(input[range])
            if testUrl.contains("bluejeans")
                || testUrl.contains("meet.google")
                || testUrl.contains("webex")
                || testUrl.contains("hangout")
                || testUrl.contains("whereby")
                || testUrl.contains ("zoom") {
                joinUrl = testUrl
                break
            }
        }
        
        return joinUrl
    }
    
    func getType(joinUrl: String) -> String {
        var type = ""
        
        if joinUrl.contains("bluejeans") {
            type = "BlueJeans"
        }
        else if joinUrl.contains("meet.google") {
            type = "Google Meet"
        }
        else if joinUrl.contains("webex") {
            type = "WebEx"
        }
        
        return type
    }
}
