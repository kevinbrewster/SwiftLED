//
//  File.swift
//  
//
//  Created by Kevin Brewster on 11/25/19.
//

import Foundation


public class RepeatEvent : SequentialEventGroup {
    var repeatCount: Int
    private var remainingRepeats = 0
        
    init(repeatCount: Int, events: [Event], delay: TimeInterval = 0) {
        self.repeatCount = repeatCount
        self.remainingRepeats = repeatCount
        super.init(events: events, delay: delay)
    }
    override func finish() {
        
        if remainingRepeats > 0 {
            // run all the events again
            super.reset()
            remainingRepeats -= 1
            time = delay
            state = .inProgress
            
        } else {
            super.finish()
        }
    }
    override public func reset() {
        remainingRepeats = repeatCount
        super.reset()
    }
}
