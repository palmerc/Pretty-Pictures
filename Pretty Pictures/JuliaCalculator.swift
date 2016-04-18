import Foundation



public class JuliaCalculator: Calculator
{
    var queue = dispatch_queue_create("JuliaCalculator", nil)

    public func fractalStatesForComplexGrid(complexGrid: [[Complex<Double>]], coordinate: Complex<Double>, maximumIterations: Int, degree: Int = 2, withCompletionHandler handler: (([[FractalState]])->())?)
    {
        if let handler = handler {
            dispatch_async(self.queue) {
                let fractalStates = self.fractalStatesForComplexGrid(complexGrid, coordinate: coordinate, maximumIterations: maximumIterations, degree: degree)
                dispatch_async(dispatch_get_main_queue(), {
                    handler(fractalStates);
                })
            }
        }
    }

    public func fractalStatesForComplexGrid(complexGrid: [[Complex<Double>]],
                                            coordinate: Complex<Double>,
                                            maximumIterations: Int,
                                            degree: Int = 2) -> [[FractalState]]
    {
        let fractalStates = complexGrid.map {
            (complexVector: [Complex<Double>]) -> [FractalState] in
            complexVector.map({
                (complexPoint: Complex<Double>) -> FractalState in
                var fractalState = FractalState(iterations: 0, maximumIterations: maximumIterations, z: complexPoint, c: coordinate, degree: degree)
                computeFractalStateForPoint(&fractalState, maximumIterations: maximumIterations, degree: degree)
                return fractalState
            })
        }

        return fractalStates
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