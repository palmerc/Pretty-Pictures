import Foundation



public struct ComplexRect: Equatable, CustomStringConvertible
{
    public var topLeft: Complex
    public var bottomRight: Complex
    private(set) var bottomLeft: Complex
    private(set) var topRight: Complex

    public init(_ c1: Complex, _ c2: Complex)
    {
        let topLeftReal = min(c1.real, c2.real)
        let topLeftImaginary = max(c1.imaginary, c2.imaginary)
        let bottomRightReal = max(c1.real, c2.real)
        let bottomRightImaginary = min(c1.imaginary, c2.imaginary)
        topLeft = Complex(topLeftReal, topLeftImaginary)
        bottomRight = Complex(bottomRightReal, bottomRightImaginary)
        bottomLeft = Complex(topLeftReal, bottomRightImaginary)
        topRight = Complex(bottomRightReal, topLeftImaginary)
    }
    public var description: String
    {
        return "tl:\(topLeft), br:\(bottomRight), bl:\(bottomLeft), tr:\(topRight)"
    }
}
public func ==(lhs: ComplexRect, rhs: ComplexRect) -> Bool
{
    return (lhs.topLeft == rhs.topLeft) && (lhs.bottomRight == rhs.bottomRight)
}