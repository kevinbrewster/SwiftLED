//
//  File.swift
//  
//
//  Created by Kevin Brewster on 11/25/19.
//

import Foundation


class ColorEvent : Event {
    internal let leds: [LED]
    internal let colors: [Color]
    
    init(leds: [LED], fill: FillStyle, delay: TimeInterval = 0, endDelay: TimeInterval = 0) {
        self.leds = leds
        colors = fill.colors(total: leds.count)
        super.init(delay: delay, endDelay: endDelay)
    }
    override func step(interval: TimeInterval) {
        super.step(interval: interval)
        
        guard state == .inProgress else {
            return
        }
        
        for (i, led) in leds.enumerated() {
            led.color = colors[i]
        }
        finish()
    }
}
