//
//  Gradient.swift
//  LEDTest
//
//  Created by Kevin Brewster on 11/18/19.
//  Copyright © 2019 Kevin Brewster. All rights reserved.
//

import Foundation


struct Gradient {
    var stops: [(Color, Double)]
    
    init(stops: [(Color, Double)]) {
        self.stops = stops
    }
    init(start: Color, end: Color) {
        self.init(stops: [(start, 0), (end, 1)])
    }
    init(_ colors: [Color]) {
        self.init(stops: colors.enumerated().map { (i, color) in
            (color, Double(i) / Double(colors.count - 1))
        })
    }
    init(_ colors: Color...) {
        self.init(colors)
    }
    mutating func addStop(color: Color, at position: Double) {
        stops += [(color, position)]
    }
    
}
extension Gradient: FillStyle {
    func colors(total: Int) -> [Color] {
        guard stops.count > 0 else { return [] }
        
        let sortedStops = stops.sorted(by: { $0.1 < $1.1 })
        return (0..<total).map {
            let stepLocation = Double($0) / Double(total - 1)
            
            var prevStop = sortedStops.first!
            var nextStop = sortedStops.last!
            
            for (color, location) in sortedStops {
                if location == stepLocation {
                    return color
                }
                if location <= stepLocation {
                    prevStop = (color, location)
                }
                if location > stepLocation {
                    nextStop = (color, location)
                    break
                }
            }
            if prevStop.1 >= nextStop.1 {
                // if the stops are the same, then just return the color
                return prevStop.0
            } else {
                let fraction = stepLocation > prevStop.1 ? (stepLocation - prevStop.1) / (nextStop.1 - prevStop.1) : 0 // how far along are we between prevStop and nextStop?
                return Gradient.color(atFraction: fraction, between: prevStop.0, and: nextStop.0)
            }
        }
    }
    private static func color(atFraction fraction: Double, between start: Color, and end: Color) -> Color {
        let redDelta = (Double(end.red) - Double(start.red)) * fraction
        let greenDelta = (Double(end.green) - Double(start.green)) * fraction
        let blueDelta = (Double(end.blue) - Double(start.blue)) * fraction
        
        return Color(
            red: UInt8(Double(start.red) + redDelta),
            green: UInt8(Double(start.green) + greenDelta),
            blue: UInt8(Double(start.blue) + blueDelta)
        )
    }
}
