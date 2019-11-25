//
//  LED.swift
//  LEDTest
//
//  Created by Kevin Brewster on 11/19/19.
//  Copyright © 2019 Kevin Brewster. All rights reserved.
//

import Foundation


public class LED {
    public var color = Color(red: 0, green: 0, blue: 0)
    weak var ledStrip: LEDStrip?
    
    init(ledStrip: LEDStrip) {
        self.ledStrip = ledStrip
    }
}

extension Array where Element == LED {
    @discardableResult public func fill(_ fill: Color, delay: TimeInterval = 0, endDelay: TimeInterval = 0) -> ColorEvent {
        return self.fill(fill as FillStyle, delay: delay, endDelay: endDelay)
    }
    @discardableResult public func fill(_ fill: FillStyle, delay: TimeInterval = 0, endDelay: TimeInterval = 0) -> ColorEvent {
        let event = ColorEvent(leds: self, fill: fill, delay: delay, endDelay: endDelay)
        if let ledStrip = first?.ledStrip, ledStrip.autoAddEvents {
            ledStrip.add(event: event)
        }
        return event
    }
    @discardableResult public func animate(_ fill: Color, duration: TimeInterval, delay: TimeInterval = 0, endDelay: TimeInterval = 0, curve: BezierAnimationCurve = .linear) -> ColorAnimationEvent {
        return self.animate(fill as FillStyle, duration: duration, delay: delay, endDelay: endDelay, curve: curve)
    }
    @discardableResult public func animate(_ fill: FillStyle, duration: TimeInterval, delay: TimeInterval = 0, endDelay: TimeInterval = 0, curve: BezierAnimationCurve = .linear) -> ColorAnimationEvent {
        let event = ColorAnimationEvent(leds: self, color: fill, duration: duration, delay: delay, endDelay: endDelay, curve: curve)
        if let ledStrip = first?.ledStrip, ledStrip.autoAddEvents {
            ledStrip.add(event: event)
        }
        return event
    }
    @discardableResult public func flash(_ fill: FillStyle, duration: TimeInterval, delay: TimeInterval = 0, endDelay: TimeInterval = 0) -> SequentialEventGroup {
        guard let originalColor = first?.color else { return SequentialEventGroup(events: []) }
        
        let event = SequentialEventGroup(events: [
            ColorEvent(leds: self, fill: fill, delay: 0),
            ColorEvent(leds: self, fill: originalColor, delay: duration)
        ], delay: delay)
                        
        if let ledStrip = first?.ledStrip, ledStrip.autoAddEvents {
            ledStrip.add(event: event)
        }
        return event
    }
}

extension LED {
    @discardableResult public func fill(_ fill: Color, delay: TimeInterval = 0, endDelay: TimeInterval = 0) -> ColorEvent {
        return [self].fill(fill as FillStyle, delay: delay, endDelay: endDelay)
    }
    @discardableResult public func fill(_ fill: FillStyle, delay: TimeInterval = 0, endDelay: TimeInterval = 0) -> ColorEvent {
        return [self].fill(fill as FillStyle, delay: delay, endDelay: endDelay)
    }
    @discardableResult public func animate(_ fill: Color, duration: TimeInterval, delay: TimeInterval = 0, endDelay: TimeInterval = 0, curve: BezierAnimationCurve = .linear) -> ColorAnimationEvent {
        return [self].animate(fill, duration: duration, delay: delay, endDelay: endDelay, curve: curve)
    }
    @discardableResult public func animate(_ fill: FillStyle, duration: TimeInterval, delay: TimeInterval = 0, endDelay: TimeInterval = 0, curve: BezierAnimationCurve = .linear) -> ColorAnimationEvent {
        return [self].animate(fill, duration: duration, delay: delay, endDelay: endDelay, curve: curve)
    }
    @discardableResult public func flashColor(_ fill: FillStyle, duration: TimeInterval, delay: TimeInterval = 0, endDelay: TimeInterval = 0) -> SequentialEventGroup {
        return [self].flash(fill, duration: duration, delay: delay, endDelay: endDelay)
    }
}

