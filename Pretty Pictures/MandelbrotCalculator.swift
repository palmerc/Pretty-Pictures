import UIKit



public class MandelbrotCalculator: Calculator
{
    static let _defaultDegree: Int = 2
    static let _defaultThreshold: Double = 2.0

    var _dispatchQueue = dispatch_queue_create("MandelbrotCalculator", nil)
    var _concurrentQueue = dispatch_queue_create("ConcurrentVector", DISPATCH_QUEUE_CONCURRENT)

    public func fractalStatesForComplexGrid(complexGrid: [[Complex<Double>]], maximumIterations: Int, degree: Int = _defaultDegree, threshold: Double = _defaultThreshold, withCompletionHandler handler: (([[FractalState]])->())?)
    {
        if let handler = handler {
            dispatch_async(_dispatchQueue) {
                let fractalStates = self.fractalStatesForComplexGrid(complexGrid, maximumIterations: maximumIterations, degree: degree, threshold: threshold)
                dispatch_async(dispatch_get_main_queue(), {
                    handler(fractalStates);
                })
            }
        }
    }

    public func fractalStatesForComplexGrid(complexGrid: [[Complex<Double>]], maximumIterations: Int, degree: Int = 2, threshold: Double = 2.0) -> [[FractalState]]
    {
        var fractalStates = [[FractalState]](count: complexGrid.count, repeatedValue: [FractalState]())
        dispatch_apply(complexGrid.count, _concurrentQueue, {
            (row: Int) in
            let complexVector = complexGrid[row]
            let fractalStateVector = complexVector.map({
                (complexPoint: Complex<Double>) -> FractalState in
                var fractalState = FractalState(type: .Mandelbrot, iterations: 0, maximumIterations: maximumIterations, z: complexPoint, c: complexPoint, degree: degree, threshold: threshold)
                self.computeFractalStateForPoint(&fractalState, maximumIterations: maximumIterations, degree: degree, threshold: threshold)
                return fractalState
            })

            fractalStates[row] = fractalStateVector
        })

        return fractalStates
    }

    private func computeFractalStateForPoint(inout mandelbrotState: FractalState, maximumIterations: Int, degree: Int, threshold: Double)
    {
        // Calculate whether the point is inside or outside the Mandelbrot set
        // Zn+1 = (Zn)^2 + c -- start with Z0 = 0
        var iterations = mandelbrotState.iterations
        var z = mandelbrotState.z
        let c = mandelbrotState.c

        for iteration in 1...maximumIterations {
            z = pow(z, degree) + c
            if abs(z) > threshold {
                iterations = iteration
                break;
            }
        }

        mandelbrotState.iterations = iterations
        mandelbrotState.z = z
    }
}