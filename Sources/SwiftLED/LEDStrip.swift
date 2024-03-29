//
//  LEDStrip.swift
//  LEDTest
//
//  Created by Kevin Brewster on 11/19/19.
//  Copyright © 2019 Kevin Brewster. All rights reserved.
//

import Foundation


public class LEDStrip {
    let numberOfLeds: Int
    var refreshInterval: TimeInterval = 0.01 {
        didSet {
            setupRefreshTimer(interval: refreshInterval)
        }
    }
    
    public private(set) var leds: [LED] = []
    public var didRefresh: (() -> Void)?
    
    internal var autoAddEvents = true
    
    private let refreshQueue = DispatchQueue.main // DispatchQueue(label: "LEDStrip")
    private var refreshTimer: DispatchSourceTimer?
    private var lastTime: TimeInterval? = nil
    
    public init(numberOfLeds: Int) {
        //self.ws281x = WS281x(pwm, type: .WS2812B, numElements: numberOfLeds)
        self.numberOfLeds = numberOfLeds
                
        self.setupRefreshTimer(interval: refreshInterval)
        
        self.leds = (0..<numberOfLeds).map { _ in LED(ledStrip: self) }
    }
    private func setupRefreshTimer(interval: TimeInterval) {
        refreshTimer = DispatchSource.makeTimerSource(queue: refreshQueue)
        refreshTimer?.schedule(deadline: .now(), repeating: .milliseconds(Int(refreshInterval * 1000)), leeway: .milliseconds(2))
        refreshTimer?.setEventHandler { [weak self] in
            self?.refresh()
        }
        refreshTimer?.resume()
    }
    private func refresh() {
        // Find the actual interval since last refresh
        let now = Date().timeIntervalSince1970
        let interval: TimeInterval
        if let lastTime = lastTime {
            interval = now - lastTime
        } else {
            interval = 0
        }
        lastTime = Date().timeIntervalSince1970
        
        
        var eventIndicesToRemove = [Int]()
        
        for (index, event) in events.enumerated() {
            event.step(interval: interval)

            if event.state == .finished {
                eventIndicesToRemove += [index]
            }
        }
        
        for index in eventIndicesToRemove.sorted(by: { $0 > $1 }) {
            events.remove(at: index)
        }
        
        self.didRefresh?()
    }
    deinit {
        refreshTimer?.cancel()
    }
    
    
    private var events: [Event] = []
    public func add(event: Event) {
        refreshQueue.async { [weak self] in
            self?.events += [event]
        }
    }
}


extension LEDStrip {
    @discardableResult public func animate(_ fill: Color, duration: TimeInterval, delay: TimeInterval = 0, endDelay: TimeInterval = 0, curve: BezierAnimationCurve = .linear) -> ColorAnimationEvent {
        return leds.animate(fill, duration: duration, delay: delay, endDelay: endDelay, curve: curve)
    }
    @discardableResult public func animate(_ fill: FillStyle, duration: TimeInterval, delay: TimeInterval = 0, endDelay: TimeInterval = 0, curve: BezierAnimationCurve = .linear) -> ColorAnimationEvent {
        return leds.animate(fill, duration: duration, delay: delay, endDelay: endDelay, curve: curve)
    }
    @discardableResult public func animate(_ fill: Color, start: Range<Int>, end: Range<Int>, duration: TimeInterval, fillSize: Int? = nil) -> RangeAnimationEvent {
        return self.animate(fill as FillStyle, start: start, end: end, duration: duration, fillSize: fillSize)
    }
    @discardableResult public func animate(_ fill: FillStyle, start: Range<Int>, end: Range<Int>, duration: TimeInterval, fillSize: Int? = nil) -> RangeAnimationEvent {
        let event = RangeAnimationEvent(leds: leds, fill: fill, start: start, end: end, duration: duration, wrapAt: leds.count, fillSize: fillSize)
        if autoAddEvents {
            add(event: event)
        }
        return event
    }
    @discardableResult public func fill(_ fill: Color, delay: TimeInterval = 0, endDelay: TimeInterval = 0) -> ColorEvent {
        return leds.fill(fill as FillStyle, delay: delay)
    }
    @discardableResult public func fill(_ fill: FillStyle, delay: TimeInterval = 0, endDelay: TimeInterval = 0) -> ColorEvent {
        return leds.fill(fill as FillStyle, delay: delay)
    }
}



@_functionBuilder
public struct EventBuilder {
    public static func buildBlock(_ events: Event...) -> [Event] {
        return events
    }
    public static func buildBlock(_ events: [Event]) -> [Event] {
        return events
    }
}


extension LEDStrip {
    @discardableResult public func sequence(delay: TimeInterval = 0, @EventBuilder _ content: () -> [Event]) -> SequentialEventGroup {
        let _autoAddEvents = autoAddEvents
        autoAddEvents = false
        let events = content()
        autoAddEvents = _autoAddEvents
        
        let event = SequentialEventGroup(events: events, delay: delay)
        if autoAddEvents {
            add(event: event)
        }
        return event
    }
    @discardableResult public func sequence(delay: TimeInterval = 0, @EventBuilder _ content: () -> Event) -> SequentialEventGroup {
        return sequence(delay: delay, { [content()] })
    }
    
    
    @discardableResult public func `repeat`(_ count: Int, delay: TimeInterval = 0, @EventBuilder _ content: () -> [Event]) -> RepeatEvent {
        let _autoAddEvents = autoAddEvents
        autoAddEvents = false
        let events = content()
        autoAddEvents = _autoAddEvents
        
        let repeatEvent = RepeatEvent(repeatCount: count, events: events, delay: delay)
        if autoAddEvents {
            add(event: repeatEvent)
        }
        return repeatEvent
    }
    
    @discardableResult public func `repeat`(_ count: Int, delay: TimeInterval = 0, @EventBuilder _ content: () -> Event) -> RepeatEvent {
        return `repeat`(count, delay: delay, { [content()] })
    }
    @discardableResult public func repeatForever(delay: TimeInterval = 0, @EventBuilder _ content: () -> [Event]) -> RepeatEvent {
        return `repeat`(.max, delay: delay, { content() })
    }
    @discardableResult public func repeatForever(delay: TimeInterval = 0, @EventBuilder _ content: () -> Event) -> RepeatEvent {
        return `repeat`(.max, delay: delay, { [content()] })
    }
}




