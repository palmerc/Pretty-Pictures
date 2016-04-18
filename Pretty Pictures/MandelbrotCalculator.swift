import UIKit


public struct FractalState
{
    var iterations: Int
    var z: Complex<Double>
    var c: Complex<Double>
}



public class MandelbrotCalculator
{
    public func pointsForComplexRect(complexRect: ComplexRect<Double>, stepSize: Double, maximumIterations: Int, degree: Int = 2) -> [FractalState]
    {
        let topLeft = complexRect.topLeft
        let realSteps = Int(floor(complexRect.width / stepSize))
        let imaginarySteps = Int(floor(complexRect.height / stepSize))

        var states = [FractalState]()
        var escapeTimes = [Int]()
        for imaginaryStep in 0 ..< imaginarySteps {
            let imaginary = topLeft.im - stepSize * Double(imaginaryStep)
            for realStep in 0 ..< realSteps {
                let real = topLeft.re + stepSize * Double(realStep)
                var mandelbrotState = FractalState(iterations: 0, z: Complex(real, imaginary), c: Complex(real, imaginary))
                computeFractalStateForPoint(&mandelbrotState, maximumIterations: maximumIterations, degree: degree)
                states.append(mandelbrotState)
                escapeTimes.append(mandelbrotState.iterations)
            }
        }

        return states
    }

    private func computeFractalStateForPoint(inout mandelbrotState: FractalState, maximumIterations: Int, degree: Int = 2)
    {
        // Calculate whether the point is inside or outside the Mandelbrot set
        // Zn+1 = (Zn)^2 + c -- start with Z0 = 0
        var iterations = mandelbrotState.iterations
        var z = mandelbrotState.z
        let c = mandelbrotState.c

        for iteration in 1...maximumIterations {
            z = pow(z, degree) + c
            if abs(z) > 2 {
                iterations = iteration
                break;
            }
        }

        mandelbrotState.iterations = iterations
        mandelbrotState.z = z
    }
}