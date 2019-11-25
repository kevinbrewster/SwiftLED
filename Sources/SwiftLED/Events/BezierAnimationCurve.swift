//
//  BezierAnimationCurve.swift
//  LEDTest
//
//  Created by Kevin Brewster on 11/18/19.
//  Copyright © 2019 Kevin Brewster. All rights reserved.
// https://gist.github.com/raphaelschaad/6739676

import Foundation


typealias Point = (x: Double, y: Double)

public struct BezierAnimationCurve {
    
    static var easeIn = BezierAnimationCurve(p1: (x: 0.42, y: 0.0), p2:(x: 1.0, y: 1.0))
    static var easeOut = BezierAnimationCurve(p1: (x: 0.0, y: 0.0), p2:(x: 0.58, y: 1.0))
    static var easeInOut = BezierAnimationCurve(p1: (x: 0.42, y: 0.0), p2:(x: 0.58, y: 1.0))
    static var linear = BezierAnimationCurve(p1: (x: 0.0, y: 0.0), p2:(x: 1.0, y: 1.0))
    
    let p1: Point
    let p2: Point
    
    private let ax: Double
    private let ay: Double
    private let bx: Double
    private let by: Double
    private let cx: Double
    private let cy: Double
    
    init(p1: Point, p2: Point) {
        self.p1 = (x: p1.x.clamped(to: 0...1), y: p1.y.clamped(to: 0...1))
        self.p2 = (x: p2.x.clamped(to: 0...1), y: p2.y.clamped(to: 0...1))
        
        // Calculate polynomial coefficients [Implicit first and last control points are (0,0) and (1,1)]
        cx = 3.0 * p1.x
        bx = 3.0 * (p2.x - p1.x) - cx
        ax = 1.0 - cx - bx
        
        cy = 3.0 * p1.y
        by = 3.0 * (p2.y - p1.y) - cy
        ay = 1.0 - cy - by
    }
    func value(for x: Double) -> Double {
        let xSolved = solveCurveX(x)
        return sampleCurveY(xSolved)
    }
    
    private func sampleCurveX(_ t: Double) -> Double {
        // 'ax t^3 + bx t^2 + cx t' expanded using Horner's rule.
        return ((ax * t + bx) * t + cx) * t
    }
    private func sampleCurveY(_ t: Double) -> Double {
        return ((ay * t + by) * t + cy) * t
    }
    private func sampleCurveDerivativeX(_ t: Double) -> Double {
        return (3.0 * ax * t + 2.0 * bx) * t + cx
    }
    private func solveCurveX(_ x: Double, epsilon: Double = 1/200) -> Double {
        
        // smaller epsilon = Higher precision in the timing function (useful for longer duration to avoid ugly discontinuities)
        // e.g. epsilon = 1.0 / (200.0 * duration)
                
        var t0: Double = 0
        var t1: Double = 0
        var t2: Double = x
        var x2: Double = 0
        var d2: Double = 0
                        
        // First try a few iterations of Newton's method -- normally very fast.
        for _ in 0..<8 {
            x2 = sampleCurveX(t2) - x
            if abs(x2) < epsilon {
                return t2
            }
            d2 = sampleCurveDerivativeX(t2)
            if abs(d2) < 1e-6 {
                break;
            }
            t2 = t2 - x2 / d2
        }
        
        // Fall back to the bisection method for reliability.
        t0 = 0.0
        t1 = 1.0
        t2 = x
        
        if t2 < t0 {
            return t0
        }
        if t2 > t1 {
            return t1
        }
        
        while t0 < t1 {
            x2 = sampleCurveX(t2)
            if abs(x2 - x) < epsilon {
                return t2;
            }
            if (x > x2) {
                t0 = t2;
            } else {
                t1 = t2;
            }
            t2 = (t1 - t0) * 0.5 + t0
        }
        
        // Failure.
        return t2
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

extension Strideable where Stride: SignedInteger {
    func clamped(to limits: CountableClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
