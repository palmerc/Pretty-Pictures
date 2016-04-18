import Foundation
import Darwin



public class ShipCalculator
{
    public func fractalStatesForComplexGrid(complexGrid: [[Complex<Double>]], maximumIterations: Int, degree: Int = 2) -> [[FractalState]]
    {
        let fractalStates = complexGrid.map {
            (complexVector: [Complex<Double>]) -> [FractalState] in
            complexVector.map({
                (complexPoint: Complex<Double>) -> FractalState in
                var fractalState = FractalState(iterations: 0, maximumIterations: maximumIterations, z: Complex(0, 0), c: complexPoint, degree: degree)
                computeFractalStateForPoint(&fractalState, maximumIterations: maximumIterations, degree: degree)
                return fractalState
            })
        }

        return fractalStates
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