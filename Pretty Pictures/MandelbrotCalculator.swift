import UIKit


public struct MandelbrotState
{
    var iterations: Int
    var z: Complex
    var c: Complex
}



public class MandelbrotCalculator
{
    public func pointsForComplexRect(complexRect: ComplexRect, realStepSize: Double, imaginaryStepSize: Double, maximumIterations: Int, degree: Int = 2) -> [MandelbrotState]
    {
        let topLeft = complexRect.topLeft
        let bottomRight = complexRect.bottomRight
        let width = abs(bottomRight.real - topLeft.real)
        let realSteps = Int(floor(width / realStepSize))
        let height = abs(topLeft.imaginary - bottomRight.imaginary)
        let imaginarySteps = Int(floor(height / imaginaryStepSize))

        var states = [MandelbrotState]()
        var escapeTimes = [Int]()
        for imaginaryStep in 0 ..< imaginarySteps {
            let imaginary = topLeft.imaginary - imaginaryStepSize * Double(imaginaryStep)
            for realStep in 0 ..< realSteps {
                let real = topLeft.real + realStepSize * Double(realStep)
                var mandelbrotState = MandelbrotState(iterations: 0, z: Complex(0, 0), c: Complex(real, imaginary))
                computeMandelbrotStateForPoint(&mandelbrotState, maximumIterations: maximumIterations, degree: degree)
                states.append(mandelbrotState)
                escapeTimes.append(mandelbrotState.iterations)
            }
        }

        return states
    }

    private func computeMandelbrotStateForPoint(inout mandelbrotState: MandelbrotState, maximumIterations: Int, degree: Int = 2)
    {
        // Calculate whether the point is inside or outside the Mandelbrot set
        // Zn+1 = (Zn)^2 + c -- start with Z0 = 0
        var iterations = mandelbrotState.iterations
        var z = mandelbrotState.z
        let c = mandelbrotState.c

        for iteration in 1...maximumIterations {
            z = z * z + c
            if abs(z) > 2 {
                iterations = iteration
                break;
            }
        }

        mandelbrotState.iterations = iterations
        mandelbrotState.z = z
    }
}