import UIKit



public class MandelbrotCalculator: Calculator
{
    var queue = dispatch_queue_create("MandelbrotCalculator", nil)

    public func fractalStatesForComplexGrid(complexGrid: [[Complex<Double>]], maximumIterations: Int, degree: Int = 2, withCompletionHandler handler: (([[FractalState]])->())?)
    {
        if let handler = handler {
            dispatch_async(self.queue) {
                let fractalStates = self.fractalStatesForComplexGrid(complexGrid, maximumIterations: maximumIterations, degree: degree)
                dispatch_async(dispatch_get_main_queue(), {
                    handler(fractalStates);
                })
            }
        }
    }

    public func fractalStatesForComplexGrid(complexGrid: [[Complex<Double>]], maximumIterations: Int, degree: Int = 2) -> [[FractalState]]
    {
        let fractalStates = complexGrid.map {
            (complexVector: [Complex<Double>]) -> [FractalState] in
            complexVector.map({
                (complexPoint: Complex<Double>) -> FractalState in
                var fractalState = FractalState(type: .Mandelbrot, iterations: 0, maximumIterations: maximumIterations, z: complexPoint, c: complexPoint, degree: degree)
                computeFractalStateForPoint(&fractalState, maximumIterations: maximumIterations, degree: degree)
                return fractalState
            })
        }

        return fractalStates
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