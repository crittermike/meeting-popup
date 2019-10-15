//
//  ContentView.swift
//  Meeting Popup
//
//  Created by Mike Crittenden on 10/9/19.
//  Copyright © 2019 Mike Crittenden. All rights reserved.
//

import SwiftUI
import EventKit

struct ContentView: View {
    
    @ObservedObject var eventService = EventService()

    var body: some View {
        VStack {
            Text("Hey dummy! Join your meeting!")
                .font(.subheadline)
                .foregroundColor(Color.gray)
            Text(eventService.title)
                .font(.largeTitle)
                .foregroundColor(Color.white)
                .padding(.top)
            
            if eventService.type != "" {
                Button(action: {
                    let joinUrl = URL(string: "\(self.eventService.joinUrl)")!
                    NSWorkspace.shared.open(joinUrl)
                    NSApp.hide(nil)
                }) {
                    Text("Join \(eventService.type)")
                }
            }

            Button(action: {
                NSApp!.hide(nil)
            }) {
                Text("I joined!")
            }
        }
        .padding(.all)
        .frame(minWidth: 1000, minHeight: 750)
    }
}
 

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
