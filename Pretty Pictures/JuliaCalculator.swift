import Foundation



public class JuliaCalculator
{
    public func pointsForComplexRect(complexRect: ComplexRect<Double>, coordinate: (u: Double, v: Double), stepSize: Double, maximumIterations: Int, degree: Int = 2) -> [FractalState]
    {
        let topLeft = complexRect.topLeft
        let realSteps = Int(floor(complexRect.width / stepSize))
        let imaginarySteps = Int(floor(complexRect.height / stepSize))

        var states = [FractalState]()
        for imaginaryStep in 0 ..< imaginarySteps {
            let imaginary = topLeft.im - stepSize * Double(imaginaryStep)
            for realStep in 0 ..< realSteps {
                let real = topLeft.re + stepSize * Double(realStep)
                var juliaState = FractalState(iterations: 0, z: Complex(real, imaginary), c: Complex(coordinate.u, coordinate.v))
                computeFractalStateForPoint(&juliaState, maximumIterations: maximumIterations, degree: degree)
                states.append(juliaState)
            }
        }

        return states
    }

    private func computeFractalStateForPoint(inout fractalState: FractalState, maximumIterations: Int, degree: Int = 2)
    {
        // Calculate whether the point is inside or outside the Mandelbrot set
        // Zn+1 = (Zn)^2 + c -- start with Z0 = 0
        var iterations = fractalState.iterations
        var z = fractalState.z
        let c = fractalState.c

        for iteration in 1...maximumIterations {
            z = pow(z, degree) + c
            if abs(z) > 2 {
                iterations = iteration
                break;
            }
        }

        fractalState.iterations = iterations
        fractalState.z = z
    }
}