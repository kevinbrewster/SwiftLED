# SwiftLED

SwiftLED is a high-level library to control addressable LEDs (e.g. WS2812/NeoPixel) with animations and effects. It's designed to run on a Raspberry Pi.

There is a companion app for MacOS called [SwiftLEDSimulator](https://github.com/kevinbrewster/SwiftLEDSimulator) that allows you to test out your LED programs before sending your code to the embedded device (e.g. Raspberry Pi). 

*The animations below are screenshots from this app.*

1. [Static Examples](#static-examples)
2. [Animation Examples](#animation-examples)
3. [Supported Hardware](#supported-hardware)
4. [Installation](#installation)
5. [Usage](#usage)
6. [How It Works](#how-it-works)

---

### Static Examples:

#### Set Single LED Color
```swift
ledStrip.leds[5].fill(.orange)
```
![](https://github.com/kevinbrewster/Documentation/blob/master/SwiftLED/single_color_orange.png)

---

#### Set All LED's Color
```swift
ledStrip.fill(Color(red: 0, green: 100, blue: 155))
```
![](https://github.com/kevinbrewster/Documentation/blob/master/SwiftLED/teal_fill.png)

---

#### Set Every Fifth LED's Color
```swift
let leds = stride(from: 0, to: ledStrip.leds.count, by: 5).map { ledStrip.leds[$0] }
leds.fill(.green)
```
![](https://github.com/kevinbrewster/Documentation/blob/master/SwiftLED/every_5_fill.png)

---

#### Fill All LEDs with Gradient
```swift
ledStrip.fill(Gradient(.red, .orange, .yellow, .orange, .red))
```
![](https://github.com/kevinbrewster/Documentation/blob/master/SwiftLED/gradient_fill.png)

---

### Animation Examples:

#### Single Color LED Move
```swift
ledStrip.repeatForever {
  ledStrip.animate(.red, start: 0..<1, end: 45..<46, duration: 2.0)
  ledStrip.animate(.green, start: 0..<1, end: 45..<46, duration: 2.0)
  ledStrip.animate(.blue, start: 0..<1, end: 45..<46, duration: 2.0)
}
```
![](https://github.com/kevinbrewster/Documentation/blob/master/SwiftLED/single_loop.png)

---

#### Dual Color LED Move
```swift
ledStrip.repeatForever {
  ledStrip.animate(.red, start: 45..<47, end: 0..<2, duration: 2.0)
  ledStrip.animate(.green, start: 0..<2, end: 45..<47, duration: 2.0)
  ledStrip.animate(.blue, start: 45..<47, end: 0..<2, duration: 2.0)
}
```
![](https://github.com/kevinbrewster/Documentation/blob/master/SwiftLED/dual_loop.png)

---

#### Color Wipes
```swift
ledStrip.repeatForever {
  ledStrip.animate(.red, start: 0..<1, end: 0..<45, duration: 1.0)
  ledStrip.animate(.green, start: 0..<1, end: 0..<45, duration: 1.0)
  ledStrip.animate(.blue, start: 0..<1, end: 0..<45, duration: 1.0)
}
```
![](https://github.com/kevinbrewster/Documentation/blob/master/SwiftLED/color_wipe.png)

---

#### Comet
```swift
ledStrip.repeat(3) {
  ledStrip.animate(Gradient(.black, .white), start: 0..<6, end: 45..<51, duration: 2)
}
```
![](https://github.com/kevinbrewster/Documentation/blob/master/SwiftLED/comet.png)

---

#### Rainbow Gradient Color Wipe
```swift
let rainbow = Gradient(.red, .green, .blue, .red)

ledStrip.repeat(2) {
  ledStrip.animate(rainbow, start: 0..<1, end: 0..<180, duration: 2.0, fillSize: 180)
}
```
![](https://github.com/kevinbrewster/Documentation/blob/master/SwiftLED/gradient_wipe.png)

---

#### Moving Rainbow Gradient
```swift
let rainbow = Gradient(.red, .green, .blue, .red)

ledStrip.repeat(2) {
  ledStrip.animate(rainbow, start: 0..<45, end: 45..<90, duration: 2.0)
}
```
![](https://github.com/kevinbrewster/Documentation/blob/master/SwiftLED/gradient_move.gif)

---

#### Theatre Chase
```swift
let rainbow = Gradient(.red, .green, .blue, .red)

ledStrip.sequence {
  ledStrip.threatreChase(.red, repeatCount: 30)
  ledStrip.threatreChase(rainbow, repeatCount: 30)
}
```
![](https://github.com/kevinbrewster/Documentation/blob/master/SwiftLED/theatre_chase.gif)

---

#### Pulse Effect stacked with Popcorn Effect
```swift
ledStrip.repeatForever {
    ledStrip.animate(Color(red: 200, green: 0, blue: 0), duration: 3.0, curve: .easeOut)
    ledStrip.animate(Color(red: 20, green: 0, blue: 0), duration: 3.0, curve: .easeIn)
}
ledStrip.popcorn(Color(red: 255, green: 0, blue: 0), averagePopsPerSecond: 6, averagePopDuration: 0.6)
```
![](https://github.com/kevinbrewster/Documentation/blob/master/SwiftLED/pulse_popcorn.gif)

---


### Supported LEDs:
1. WS2812 / WS2812b (aka NeoPixel)



### How it works

