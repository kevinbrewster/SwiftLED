//
//  Examples.swift
//  LEDTest
//
//  Created by Kevin Brewster on 11/21/19.
//  Copyright © 2019 Kevin Brewster. All rights reserved.
//

import Foundation

class TheatreChaseEvent : ConcurrentEventGroup {
    init(leds: [LED], fill: FillStyle, repeatCount: Int, flashDuration: TimeInterval) {
        
        var events = [Event]()
        
        for i in 0..<3 {
            let leds = stride(from: i, to: leds.count, by: 3).map { leds[$0] }
            
            let repeatEvent = RepeatEvent(repeatCount: repeatCount, events: [
                leds.fill(fill, endDelay: flashDuration),
                leds.fill(Color.black, endDelay: flashDuration * 2)
            ], delay: TimeInterval(i) * flashDuration)
            
            events += [repeatEvent]
        }
        super.init(events: events)
        
    }
    
}

extension LEDStrip {
    @discardableResult public func threatreChase(_ fill: FillStyle, repeatCount: Int) -> Event {
        let event = TheatreChaseEvent(leds: leds, fill: fill, repeatCount: repeatCount, flashDuration: 0.08)
        if autoAddEvents {
            add(event: event)
        }
        return event
    }
    @discardableResult public func threatreChase(_ fill: Color, repeatCount: Int) -> Event {
        return self.threatreChase(fill as FillStyle, repeatCount: repeatCount)
    }
}
