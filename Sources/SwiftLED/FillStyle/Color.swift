//
//  Color.swift
//  LEDTest
//
//  Created by Kevin Brewster on 11/21/19.
//  Copyright © 2019 Kevin Brewster. All rights reserved.
//

import Foundation


public protocol FillStyle {
    func colors(total: Int) -> [Color]
}

public struct Color : Equatable {
    public let red: UInt8
    public let green: UInt8
    public let blue: UInt8
    
    public init(red: UInt8, green: UInt8, blue: UInt8) {
        self.red = red
        self.green = green
        self.blue = blue
    }
    
}
extension Color {
    public static var black = Color(red: 0, green: 0, blue: 0)
    public static var blue = Color(red: 0, green: 0, blue: 0xFF)
    public static var red = Color(red: 0xFF, green: 0, blue: 0)
    public static var green = Color(red: 0, green: 0xFF, blue: 0)
    public static var white = Color(red: 0xFF, green: 0xFF, blue: 0xFF)
    public static var yellow = Color(red: 0xFF, green: 0xFF, blue: 0)
    public static var orange = Color(red: 0xFF, green: 0xA5, blue: 0)
}

extension Color: FillStyle {
    public func colors(total: Int) -> [Color] {
        return (0..<total).map { _ in self }
    }
}

extension Color {
    static func random() -> Color {
        Color(red: UInt8.random(in: 0...255), green: UInt8.random(in: 0...255), blue: UInt8.random(in: 0...255))
    }
}
public class RandomColor : FillStyle {
    public func colors(total: Int) -> [Color] {
        return (0..<total).map { _ in Color.random() }
    }
}
