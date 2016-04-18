import Foundation
import Darwin



public class ShipCalculator
{
    public func pointsForComplexRect(complexRect: ComplexRect<Double>, stepSize: Double, maximumIterations: Int, degree: Int = 2) -> [FractalState]
    {
        let topLeft = complexRect.topLeft
        let realSteps = Int(floor(complexRect.width / stepSize))
        let imaginarySteps = Int(floor(complexRect.height / stepSize))

        var states = [FractalState]()
        for imaginaryStep in 0 ..< imaginarySteps {
            let imaginary = topLeft.im - stepSize * Double(imaginaryStep)
            for realStep in 0 ..< realSteps {
                let real = topLeft.re + stepSize * Double(realStep)
                var shipSate = FractalState(iterations: 0, maximumIterations: maximumIterations, z: Complex(0, 0), c: Complex(real, imaginary), degree: degree)
                computeFractalStateForPoint(&shipSate, maximumIterations: maximumIterations, degree: degree)
                states.append(shipSate)
            }
        }

        return states
    }

    private func computeFractalStateForPoint(inout fractalState: FractalState, maximumIterations: Int, degree: Int = 2)
    {
        var iterations = fractalState.iterations
        var z = fractalState.z
        let c = fractalState.c

        for iteration in 1...maximumIterations {
            let real = (z.re * z.re) - (z.im * z.im) - c.re;
            let imaginary = 2.0 * abs(z.re * z.im) - c.im;
            z.re = real
            z.im = imaginary
            if abs(z) > 10 {
                iterations = iteration
                break;
            }
        }

        fractalState.iterations = iterations
        fractalState.z = z
    }
}