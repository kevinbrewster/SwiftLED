//
//  File.swift
//  
//
//  Created by Kevin Brewster on 11/25/19.
//

import Foundation


class PopcornEvent : ColorEvent {
    var activeLEDs = [Int: (Color, TimeInterval)]()
     
    var averagePopsPerSecond: Int = 5
    var averagePopDuration: TimeInterval = 0.5
    var prefersSpacingOut = true
        
    init(leds: [LED], fill: FillStyle, averagePopsPerSecond: Int, averagePopDuration: TimeInterval, delay: TimeInterval = 0, endDelay: TimeInterval = 0) {
        self.averagePopsPerSecond = averagePopsPerSecond
        self.averagePopDuration = averagePopDuration
        super.init(leds: leds, fill: fill, delay: delay, endDelay: endDelay)
    }
    override func step(interval: TimeInterval) {
        guard interval > 0 else { return }
             
        for (index, (originalColor, timeRemaining)) in activeLEDs {
            activeLEDs[index] = (originalColor, timeRemaining - interval)

            if timeRemaining - interval <= 0 {
                leds[index].color = originalColor
                
                if timeRemaining - interval < averagePopDuration * 4 {
                    // keep a record of this LED to help with spacing out future leds
                    activeLEDs[index] = nil
                }
            } else {
                leds[index].color = colors[index]
            }
        }
                        
        var totalLedsToFlash = interval * Double(averagePopsPerSecond)
        
        if totalLedsToFlash < 1 {
            // roll the dice
            let max = Int(1 / totalLedsToFlash)
            let r = Int.random(in: 0..<Int(max))
            if r == 0 {
                totalLedsToFlash = 1
            }
        }
        for _ in 0..<Int(floor(totalLedsToFlash)) {
            flashRandom()
        }
    }
    func minDistanceToLitLeds(_ index: Int) -> Int {
        var minDist = leds.count
        for (i, _) in activeLEDs {
            let dist = min(abs(index - i), abs( (index - leds.count) - i))
            if dist < minDist {
                minDist = dist
            }
        }
        return minDist
    }
    private func flashRandom() {
        var eligibleLedIndices = (0..<leds.count).filter({ activeLEDs[$0] == nil })
        guard eligibleLedIndices.count > 0 else { return }
                
        if prefersSpacingOut {
            // filter down to the 1/4 the leds with greatest distance from recently lit ones
            eligibleLedIndices = eligibleLedIndices.sorted { minDistanceToLitLeds($0) > minDistanceToLitLeds($1) }
            eligibleLedIndices = Array(eligibleLedIndices[0..<max(1,eligibleLedIndices.count/4)])
        }
        
        let randomDuration = Double.random(in: (averagePopDuration * 0.5)..<(averagePopDuration * 1.5))
        let randomIndex = eligibleLedIndices[Int.random(in: 0..<eligibleLedIndices.count)]
                
        activeLEDs[randomIndex] = (leds[randomIndex].color, randomDuration)
        leds[randomIndex].color = colors[randomIndex]
    }
}
extension LEDStrip {
    @discardableResult func popcorn(_ fill: FillStyle, averagePopsPerSecond: Int, averagePopDuration: TimeInterval) -> Event {
        let event = PopcornEvent(leds: leds, fill: fill, averagePopsPerSecond: averagePopsPerSecond, averagePopDuration: averagePopDuration)
        if autoAddEvents {
            add(event: event)
        }
        return event
    }
    
}
