//
//  Event.swift
//  LEDTest
//
//  Created by Kevin Brewster on 11/19/19.
//  Copyright © 2019 Kevin Brewster. All rights reserved.
//

import Foundation

public enum EventState {
    case delayed
    case inProgress
    case endDelayed
    case finished
}

public class Event {
    internal var delay: TimeInterval = 0
    internal var endDelay: TimeInterval = 0
    
    var state: EventState = .delayed
    
    public init(delay: TimeInterval = 0, endDelay: TimeInterval = 0) {
        self.delay = delay
        self.endDelay = endDelay
    }
    
    internal var time: TimeInterval! = nil
    public func step(interval: TimeInterval) {
        if time == nil {
            time = 0
        } else {
            time += interval
        }
        
        switch state {
            case .delayed where time >= delay:
                state = .inProgress
            
            case .endDelayed where time >= delay + endDelay:
                state = .finished
            
            default: ()
        }
    }
    public func reset() {
        time = nil
        state = .delayed
    }
    internal func finish() {
        //print("Event->finish()")
        if endDelay > 0 {
            state = .endDelayed
        } else {
            state = .finished
        }
    }
    public func endDelay(_ endDelay: TimeInterval) -> Self {
        self.endDelay = endDelay
        return self
    }
}

public class BlockEvent : Event {
    var block: () -> Bool
    
    public init(block: @escaping () -> Bool) {
        self.block = block
        super.init()
    }
    override public func step(interval: TimeInterval) {
        if block() {
            state = .finished
        }
    }
}
