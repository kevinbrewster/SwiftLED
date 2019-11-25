//
//  File.swift
//  
//
//  Created by Kevin Brewster on 11/25/19.
//

import Foundation


public class ConcurrentEventGroup : Event {
    var events: [Event]
    
    init(events: [Event], delay: TimeInterval = 0) {
        self.events = events
        super.init(delay: delay)
    }
    override public func step(interval: TimeInterval) {
        super.step(interval: interval)
        guard state == .inProgress else {
            return
        }
        for event in events {
            if event.state != .finished {
                event.step(interval: interval)
            }
        }
        if events.filter({ $0.state != .finished }).count == 0 {
            state = .finished
        }
    }
    override public func reset() {
        for event in events {
            event.reset()
        }
        super.reset()
    }
}
    
    
public class SequentialEventGroup : Event {
    // Sequentially run events
    var events: [Event]
    
    private var currentEventIndex = 0
    
    init(events: [Event], delay: TimeInterval = 0) {
        self.events = events
        super.init(delay: delay)
        
        //NSLog("RepeatEvent init \(events.count)")
    }
    
    
    override public func step(interval: TimeInterval) {
        super.step(interval: interval)
        guard state == .inProgress else {
            return
        }
        
        guard currentEventIndex < events.count else {
            state = .finished
            return
        }
        
        events[currentEventIndex].step(interval: interval)
        
        switch events[currentEventIndex].state {
            case .finished:
                if currentEventIndex == events.count - 1 {
                    finish()
                } else {
                    currentEventIndex += 1
                }
                if state == .inProgress {
                    events[currentEventIndex].step(interval: interval) // step the next event right away
                }
            default:
                state = .inProgress
        }
    }
    override public func reset() {
        currentEventIndex = 0
        
        for event in events {
            event.reset()
        }
        super.reset()
    }
}
