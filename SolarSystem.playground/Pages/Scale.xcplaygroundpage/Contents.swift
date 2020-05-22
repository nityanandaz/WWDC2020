import PlaygroundSupport

PlaygroundPage.current.setLiveView(ExportScaleView())

//: # The Scale of the Solar System
//:
//: On this page you will see nothing at first, except for some stars.
//: However, the problem is not, that there's nothing here.
//: In fact, I drew Mercury, Venus, Earth, Mars, Jupiter, Saturn, Uranus, Neptun, Pluto, and the Sun on the screen, but their diameter is so tiny compared to their distance to each other. that you cannot see them.
//:
//: _Toggle the Switch for more control._
//:
//: I tried many different scaling techniques until I fount that it is best to take the root of all measurements.
//: The underlying goal was to remain accurate regarding their ratios among each other.
//: Specifically, I considered the celestial bodies' diameters and their distance to the Sun, also called the semi major axis.
//:
//: Still, the sun can barely be seen on the left of the screen.
//:
//: _Scale the bodies by a factor. Their distances will remain fix._

//: [Previous](@previous)
//: [Next](@next)
