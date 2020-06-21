import SwiftUI

// MARK: - Data

fileprivate let bodyColors: [String: UIColor] = [
    "Sun": #colorLiteral(red: 0.9637205005, green: 0.9525749087, blue: 0.3427081406, alpha: 1),
    "Mercury": #colorLiteral(red: 0.7648453116, green: 0.7403973937, blue: 0.7406902313, alpha: 1),
    "Venus": #colorLiteral(red: 0.7863627076, green: 0.7724788785, blue: 0.737626493, alpha: 1),
    "Earth": #colorLiteral(red: 0.3791742921, green: 0.3979392648, blue: 0.5947939754, alpha: 1),
    "Mars": #colorLiteral(red: 0.7046307325, green: 0.5196846724, blue: 0.3231036067, alpha: 1),
    "Jupiter": #colorLiteral(red: 0.6111262441, green: 0.5392029285, blue: 0.4832848907, alpha: 1),
    "Saturn": #colorLiteral(red: 0.8150859475, green: 0.7153324485, blue: 0.5843099952, alpha: 1),
    "Uranus": #colorLiteral(red: 0.7638471723, green: 0.9141293168, blue: 0.9246692061, alpha: 1),
    "Neptun": #colorLiteral(red: 0.4130792022, green: 0.5184828043, blue: 0.6927860379, alpha: 1),
    "Pluto": #colorLiteral(red: 0.832434833, green: 0.6942101121, blue: 0.5591949224, alpha: 1),
]

extension CelestialBody {
    var color: Color {
        Color(bodyColors[name]!)
    }
}

fileprivate let bodiesData = """
name,mass (in kg),diameter (in km),semi-major-axis (in AE), sidereal-year (in d)
Sun,1.9884e30,696342,0.0,0.0
Mercury,3.301e23,4879.4,0.3871,87.969
Venus,4.875e24,12103.6,0.723,244.701
Earth,5.9724e24,12713.50,1.0,365.256
Mars,6.417e23,6752.4,1.524,686.980
Jupiter,1.899e27,133708,5.204,4332.816
Saturn,5.685e26,108728,9.5826,10759.345992
Uranus,8.683e25,49946,19.201,32511.801816
Neptun,1.0243e26,48682,30.070,71878.72824
Pluto,1.303e23,2374,39.482,90561.232
"""

struct CelestialBody {
    let name: String
    let mass: Measurement<UnitMass>
    let diameter: Measurement<UnitLength>
    let semiMajorAxis: Measurement<UnitLength>
    let siderialYear: Measurement<UnitDuration>
}

extension CelestialBody {
    static func make<S: StringProtocol>(from csvRow: S) -> CelestialBody {
        let split = csvRow.split(separator: ",")
        
        guard let mass = Double(split[1]),
            let diameter = Double(split[2]),
            let semiMajorAxis = Double(split[3]),
            let siderialYear = Double(split[4]) else { fatalError() }
        
        return CelestialBody(name: String(split[0]),
                             mass: .init(value: mass, unit: .kilograms),
                             diameter: .init(value: diameter, unit: .kilometers),
                             semiMajorAxis: Measurement<UnitLength>(value: semiMajorAxis,
                                                                    unit: .astronomicalUnits).converted(to: .kilometers),
                             siderialYear: Measurement<UnitDuration>(value: siderialYear, unit: .days))
    }
    
    static let all: [CelestialBody] = {
        let rows = bodiesData.split(separator: "\n")
        let bodies = rows.dropFirst().map(CelestialBody.make(from:))
        
        return bodies
    }()
}

extension UnitDuration {
    static let days = UnitDuration(symbol: "d", converter: UnitConverterLinear(coefficient: 24 * 60 * 60))
    static let years = UnitDuration(symbol: "a", converter: UnitConverterLinear(coefficient: 365.256 * 24 * 60 * 60))
}

// MARK: - Views

struct ScaleView: View {
    let bodies: [CelestialBody]
    let magicNumber: Double
    
    init() {
        self.bodies = CelestialBody.all
        self.magicNumber = 13.0
    }
    
    @State
    private var doRoot = false
    
    @State
    private var magicNumberFraction = 0.0
    
    var body: some View {
        VStack {
            GeometryReader(content: makeView)
                .background(SpaceView(starCount: 500))
            VStack {
                Toggle(isOn: $doRoot) {
                    Text("Take the square root of all measurements")
                }
                if doRoot {
                    Slider(value: $magicNumberFraction)
                        .frame(width: 200.0)
                    Text("Scale bodies by an empirical factor")
                }
            }
            .padding()
        }
    }
    
    func makeView(_ geometry: GeometryProxy) -> some View {
        let divisor = bodies.map(\.diameter.value).min()!
        
        let elements: [(diameter: Double, distance: Double)]
        elements = bodies.map { (body) in
            var diameter = body.diameter.value / divisor
            var distance = body.semiMajorAxis.value / divisor
            
            if doRoot {
                diameter = sqrt(diameter)
                diameter *= 1.0 + magicNumberFraction * (magicNumber - 1.0)
                distance = sqrt(distance)
            }
            
            return (diameter, distance)
        }
        
        let factor = elements.map(\.1).max()!
        let coefficient = geometry.size.width / CGFloat(factor)
        
        let values = Array(elements.enumerated())
        
        return ForEach(values, id: \.0) { (value) in
            Circle()
                .fill(self.bodies[value.0].color)
                .frame(width: coefficient * CGFloat(value.1.diameter),
                       height: coefficient * CGFloat(value.1.diameter))
                .position(x: coefficient * CGFloat(value.1.distance),
                          y: geometry.size.height / 2.0)
            
        }
    }
}

struct AnimatedSolarSystemView: View {
    let bodies: [CelestialBody]
    let magicNumber: Double
    
    init() {
        self.bodies = CelestialBody.all
        self.magicNumber = 13.0 / 2.0
    }
    
    @State
    var animationFlag = false
    
    var body: some View {
        GeometryReader(content: self.makeView)
            .aspectRatio(1, contentMode: .fill)
            .background(SpaceView(starCount: 200))
            .padding()
            .onAppear {
                self.animationFlag.toggle()
        }
    }
    
    func makeView(_ geometry: GeometryProxy) -> some View {
        let divisor = bodies.map(\.diameter.value).min()!
        
        typealias ViewModel = (diameter: Double, distance: Double, color: Color, animation: Animation)
        
        let viewModels: [ViewModel] = bodies.map { (body) in
            var diameter = body.diameter.value / divisor
            var distance = body.semiMajorAxis.value / divisor
            
            diameter = sqrt(diameter)
            diameter *= magicNumber
            distance = sqrt(distance)
            
            let siderialYear = body.siderialYear.converted(to: .years).value
            let animation = Animation
                .linear(duration: self.animationFlag ? 30.0 * siderialYear : 0.0)
                .repeatForever(autoreverses: false)
            
            let color = body.color
            return (diameter, distance, color, animation)
        }
        
        let factor = viewModels.map(\.distance).max()!
        let coefficient = geometry.size.height / CGFloat(factor)
        
        let values = Array(viewModels.enumerated())
        
        let inner = ForEach(values, id: \.0) { (value) in
            HStack {
                Spacer(minLength: 0.0)
                Circle()
                    .fill(value.1.color)
                    .frame(width: coefficient * CGFloat(value.1.diameter),
                           height: coefficient * CGFloat(value.1.diameter))
            }
            .padding(CGFloat(geometry.size.height -
                coefficient * CGFloat(value.1.distance) -
                coefficient * CGFloat(value.1.diameter)) / 2.0)
                .animation(nil)
                .rotationEffect(Angle(degrees: self.animationFlag ? 360.0 : 0.0))
                .animation(value.1.animation)
        }
        
        return ZStack {
            inner
        }
    }
}

struct SpaceView: View {
    let starCount: Int

    var body: some View {
        ZStack {
            Color.black
            GeometryReader { (proxy) in
                ForEach(0..<self.starCount) { (_) in
                    Circle()
                        .fill(Color.white)
                        .frame(width: 2.0, height: 2.0)
                        .position(CGPoint(x: CGFloat.random(in: 0.0...proxy.size.width),
                                          y: CGFloat.random(in: 0.0...proxy.size.height)))
                }
            }
        }
    }
}

// MARK: - Export

public struct ExportScaleView: View {
    public init() { }
    
    public var body: some View {
        ScaleView()
    }
}

public struct ExportOrbitsView: View {
    public init() { }
    
    public var body: some View {
        AnimatedSolarSystemView().padding()
    }
}
