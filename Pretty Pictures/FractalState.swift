import Foundation


enum FractalType {
    case Mandelbrot
    case Julia
    case BurningShip
}


public struct FractalState
{
    var type: FractalType
    var iterations: Int
    var maximumIterations: Int
    var z: Complex<Double>
    var c: Complex<Double>
    var degree: Int
    var threshold: Double
}