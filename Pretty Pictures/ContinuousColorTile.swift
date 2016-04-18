import UIKit



public struct ContinuousColorTile : ColorTile
{
    private var _states: [FractalState]
    private var _maximumIterations: Int
    private var _width: Int
    private var _height: Int
    private var _colorSet: [UIColor]!

    private var _colors: [UIColor]?
    public var colors: [UIColor]?
    {
        mutating get {
            if self._colors == nil {
                self._colors = _states.map({
                    (state: FractalState) -> UIColor in
                    let z = state.z
                    let logZ = log(z.re * z.re + z.im * z.im) / 2.0
                    let normalized = log( logZ / log(2) ) / log(2)
                    let iterations = CGFloat(state.iterations) + 1.0 - CGFloat(normalized)
                    let percentage = iterations / CGFloat(self._maximumIterations)
                    return UIColor(hue: percentage, saturation: 1.0, brightness: 1.0, alpha: 1.0)
                })
            }

            return _colors
        }
    }

    private var _intensities: [UInt8]?
    public var intensities: [UInt8]?
    {
        mutating get {
            if self._intensities == nil {
                let values = _states.map({ (ms: FractalState) -> Int in
                    return ms.iterations
                })
                let max = values.maxElement()!
                self._intensities = _states.map({
                    (state: FractalState) -> UInt8 in
//                    let z = state.z
//                    let logZ = log(z.real * z.real + z.imaginary * z.im) / 2.0
//                    let normalized = log( logZ / log(2) ) / log(2)
//                    let iterations = CGFloat(state.iterations) + 1.0 - CGFloat(normalized)
//                    let percentage = iterations / CGFloat(self._maximumIterations)
                    let percentage = Float(state.iterations) / Float(max)
                    return UInt8(percentage * 255.0)
                })
            }

            return _intensities
        }
    }

    public var _colorLookup: [UIColor]?
    public var colorLookup: [UIColor]?
    {
        mutating get {
            if self._colorLookup == nil {
                self._colorLookup = _states.map({
                    (state: FractalState) -> UIColor in
                    return _colorSet[state.iterations]
                })
            }

            return _colorLookup
        }

    }

    init(states: [FractalState], maximumIterations: Int, width: Int, height: Int)
    {
        self._states = states
        self._maximumIterations = maximumIterations
        self._width = width
        self._height = height

        initializeColors()
    }

    private mutating func initializeColors()
    {
        self._colorSet = [UIColor]()
        for index in 0...1024 {
            let indexD = CGFloat(index)
            let color = UIColor(hue: abs(sin(indexD/30.0)),
                                saturation: 1.0,
                                brightness: indexD/100.0 + 0.8,
                                alpha: 1.0)
            self._colorSet.append(color)
        }
    }
}