//
//  File.swift
//  
//
//  Created by Kevin Brewster on 11/25/19.
//

import Foundation


class AnimationEvent : Event {
    var duration: TimeInterval
    let isReversed = false
    let curve: BezierAnimationCurve
    var fractionComplete: Double = 0
    
    init(duration: TimeInterval, delay: TimeInterval = 0, curve: BezierAnimationCurve = .linear) {
        self.duration = duration
        self.curve = curve
        super.init(delay: delay)
    }
    override func step(interval: TimeInterval) {
        super.step(interval: interval)
        
        guard state == .inProgress else {
            return
        }
        if time > delay + duration {
            fractionComplete = 1
            finish()
            
        } else if time >= delay {
            fractionComplete = (time - delay) / duration
        }
    }
}



class ColorAnimationEvent : AnimationEvent {
    internal let leds: [LED]
    private var initialColors: [(red: Double, green: Double, blue: Double)]!
    private var colorDiffs: [(red: Double, green: Double, blue: Double)]!
    private let color: FillStyle
    
    init(leds: [LED], color: FillStyle, duration: TimeInterval, delay: TimeInterval = 0, endDelay: TimeInterval = 0, curve: BezierAnimationCurve = .linear) {
        self.leds = leds
        self.color = color
        super.init(duration: duration, delay: delay, curve: curve)
    }
    
    override var fractionComplete: Double {
        didSet {
            //if fractionComplete == 0 {
            if initialColors == nil {
                // Since, we are animating from whatever the current color is, we need to calculate diffs now instead of at init
                let colors = color.colors(total: leds.count)
                initialColors = leds.map { (red: Double($0.color.red), green: Double($0.color.green), blue: Double($0.color.blue)) }
                colorDiffs = leds.enumerated().map { (i, led) in
                    (Double(colors[i].red) - initialColors[i].red, Double(colors[i].green) - initialColors[i].green, Double(colors[i].blue) - initialColors[i].blue)
                }
            }
            
            let xValue = isReversed ? 1 - fractionComplete : fractionComplete
            let yValue = curve.value(for: xValue)
            
            for (i, led) in leds.enumerated() {
                let stepColor = Color(
                    red: UInt8(initialColors[i].red + (colorDiffs[i].red * yValue)),
                    green: UInt8(initialColors[i].green + (colorDiffs[i].green * yValue)),
                    blue: UInt8(initialColors[i].blue + (colorDiffs[i].blue * yValue))
                )
                led.color = stepColor
            }
        }
    }
    
}


class RangeAnimationEvent : AnimationEvent {
    internal let leds: [LED]
    
    private let start: Range<Int>
    private let end: Range<Int>
    
    private let fill: FillStyle
    private let wrapAt: Int?
    private let fillSize: Int?
    private let colors: [Color]?
    private var wipe: Bool
    private let originalColors: [Color]?
    
    init(leds: [LED], fill: FillStyle, start: Range<Int>, end: Range<Int>, duration: TimeInterval, delay: TimeInterval = 0, curve: BezierAnimationCurve = .linear, wrapAt: Int? = nil, fillSize: Int? = nil, wipe: Bool = true) {
        self.leds = leds
        self.start = start
        self.end = end
        self.wrapAt = wrapAt
       
        self.fill = fill
        self.fillSize = fillSize
        self.wipe = wipe
        
        if let fillSize = fillSize {
            colors = fill.colors(total: fillSize)
        } else if start.count == end.count {
            colors = fill.colors(total: start.count)
        } else {
            colors = nil //the amount of colors needed is dynamic so we will generate colors on demand
        }
        
        originalColors = leds.map { $0.color }
        lastRange = start
        super.init(duration: duration, delay: delay, curve: curve)
   }

    private var lastLEDIndexes: [Int] = []
    private var lastRange: Range<Int>
    
    
    override var fractionComplete: Double {
        didSet {
            let curveValue = curve.value(for: fractionComplete)
            
            // we always need to fill in any LEDs from the last step until this one
            var lowerBound = Int( round(Double(start.lowerBound) + ((Double(end.lowerBound) - Double(start.lowerBound)) * curveValue)) )
            let upperBound = Int( round(Double(start.upperBound) + ((Double(end.upperBound) - Double(start.upperBound)) * curveValue)) )
            
            if lowerBound > lastRange.upperBound {
                lowerBound = lastRange.upperBound
            } else if lastRange.upperBound > upperBound, let wrapValue = fillSize ?? wrapAt, lastRange.upperBound == wrapValue {
                lowerBound = lastRange.upperBound - wrapValue
            }
            
            // if we have a static fill size then the colors are prefetched, otherwise we select the exact amount of colors needed to fill bounds
            let colors = self.colors ?? fill.colors(total: upperBound - lowerBound)
            
            // If not 'wiping' , reset the last LEDs to their original colors
            if let originalColors = originalColors {
                for index in lastLEDIndexes {
                    leds[index].color = originalColors[index]
                }
            }
                        
            lastLEDIndexes = []
            for i in lowerBound..<upperBound {
                var colorIndex = i
                if fillSize == nil {
                    colorIndex -= lowerBound
                }
                var ledIndex = i
                if let wrapAt = wrapAt {
                    ledIndex = ledIndex % wrapAt
                }
                if ledIndex < leds.count, colorIndex < colors.count { // sanity check
                    lastLEDIndexes += [ledIndex]
                    leds[ledIndex].color = colors[colorIndex]
                }
            }
            lastRange = lowerBound..<upperBound
        }
    }
    override func reset() {
        super.reset()
        
        if lastRange.startIndex == start.startIndex {
            lastLEDIndexes = []
        }
    }
    
}
