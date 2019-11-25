# SwiftLED

SwiftLED is a high-level library to control addressable LEDs with animations and effects. It's designed to run on a Raspberry Pi.

There is a companion app for MacOS called [SwiftLEDSimulator](https://github.com/kevinbrewster/SwiftLEDSimulator) that allows you to test out your LED programs before sending your code to the embedded device (e.g. Raspberry Pi). The animations below are screenshots from this app.


### Supported LEDs:
1. WS2812 / WS2812b (aka NeoPixel)

### Examples:

#### Single Color LED Move
```swift
ledStrip.animate(.red, start: 0..<1, end: 45..<46, duration: 2.0)
ledStrip.animate(.green, start: 0..<1, end: 45..<46, duration: 2.0)
ledStrip.animate(.blue, start: 0..<1, end: 45..<46, duration: 2.0)
```
![](https://github.com/kevinbrewster/Documentation/blob/master/SwiftLED/single_loop.png)

#### Dual Color LED Move
```swift
ledStrip.animate(.red, start: 45..<47, end: 0..<2, duration: 2.0)
ledStrip.animate(.green, start: 0..<2, end: 45..<47, duration: 2.0)
ledStrip.animate(.blue, start: 45..<47, end: 0..<2, duration: 2.0)
```
![](https://github.com/kevinbrewster/Documentation/blob/master/SwiftLED/dual_loop.png)

#### Color Wipes
```swift
ledStrip.animate(.red, start: 0..<1, end: 0..<45, duration: 1.0)
ledStrip.animate(.green, start: 0..<1, end: 0..<45, duration: 1.0)
ledStrip.animate(.blue, start: 0..<1, end: 0..<45, duration: 1.0)
```
![](https://github.com/kevinbrewster/Documentation/blob/master/SwiftLED/color_wipe.png)


#### Comet
```swift
ledStrip.repeat(3) {
  ledStrip.animate(Gradient(.black, .white), start: 0..<6, end: 45..<51, duration: 2)
}
```
![](https://github.com/kevinbrewster/Documentation/blob/master/SwiftLED/comet.png)

#### Rainbow Gradient Color Wipe
```swift
ledStrip.repeat(2) {
  ledStrip.animate(rainbow, start: 0..<1, end: 0..<180, duration: 2.0, fillSize: 180)
}
```
![](https://github.com/kevinbrewster/Documentation/blob/master/SwiftLED/gradient_wipe.png)


#### Moving Rainbow Gradient
```swift
ledStrip.repeat(2) {
  ledStrip.animate(rainbow, start: 0..<45, end: 45..<90, duration: 2.0)
}
```
![](https://github.com/kevinbrewster/Documentation/blob/master/SwiftLED/gradient_move.png)


#### Theatre Chase
```swift
class TheatreChaseEvent : ConcurrentEventGroup {
    init(leds: [LED], fill: FillStyle, repeatCount: Int, flashDuration: TimeInterval) {
        
        var events = [Event]()
        
        for i in 0..<3 {
            let leds = stride(from: i, to: leds.count, by: 3).map { leds[$0] }
            
            let repeatEvent = RepeatEvent(repeatCount: repeatCount, events: [
                leds.fill(fill, endDelay: flashDuration),
                leds.fill(Color.black, endDelay: flashDuration * 2)
            ], delay: TimeInterval(i) * flashDuration)
            
            events += [repeatEvent]
        }
        super.init(events: events)        
    }
}

ledStrip.add(event: TheatreChaseEvent(leds: leds, fill: fill, repeatCount: repeatCount, flashDuration: 0.08))
```
![](https://github.com/kevinbrewster/Documentation/blob/master/SwiftLED/theatre_chase.gif)


     
            
### How it works
