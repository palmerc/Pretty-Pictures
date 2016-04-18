import Foundation
import CoreGraphics



public struct ComplexRect<T: ArithmeticType>: Equatable, CustomStringConvertible
{
    public var topLeft: Complex<T>
    public var bottomRight: Complex<T>
    private(set) var bottomLeft: Complex<T>
    private(set) var topRight: Complex<T>
    public var width: T
    {
        return abs(self.bottomRight.re - self.topLeft.re)
    }
    public var height: T
    {
        return abs(self.bottomRight.im - self.topLeft.im)
    }

    public init(_ c1: Complex<T>, _ c2: Complex<T>)
    {
        let topLeftReal = min(c1.real, c2.real)
        let topLeftImaginary = max(c1.im, c2.im)
        let bottomRightReal = max(c1.re, c2.re)
        let bottomRightImaginary = min(c1.im, c2.im)
        topLeft = Complex<T>(topLeftReal, topLeftImaginary)
        bottomRight = Complex<T>(bottomRightReal, bottomRightImaginary)
        bottomLeft = Complex<T>(topLeftReal, bottomRightImaginary)
        topRight = Complex<T>(bottomRightReal, topLeftImaginary)
    }

    public var description: String
    {
        return "tl:\(topLeft), br:\(bottomRight), bl:\(bottomLeft), tr:\(topRight)"
    }
}
public func ==<T: ArithmeticType>(lhs: ComplexRect<T>, rhs: ComplexRect<T>) -> Bool
{
    return (lhs.topLeft == rhs.topLeft) && (lhs.bottomRight == rhs.bottomRight)
}

extension ComplexRect
{
    public func fitCGRect(toCGRect rect: CGRect) -> ComplexRect<T>
    {
        let rectWidth = T(CGRectGetWidth(rect))
        let rectHeight = T(CGRectGetHeight(rect))

        var tlr = T(topLeft.re)
        var tli = T(topLeft.im)
        var brr = T(bottomRight.re)
        var bri = T(bottomRight.im)

        let realWidth = T(abs(brr - tlr))
        let imaginaryHeight = T(abs(tli - bri))
        let realStepSize = realWidth / rectWidth
        let imaginaryStepSize = imaginaryHeight / rectHeight
        let stepSize = max(realStepSize, imaginaryStepSize)

        let calculatedWidth = realWidth / stepSize
        if calculatedWidth < rectWidth {
            let widthDifference = rectWidth - calculatedWidth
            let realWidthDifference = widthDifference * stepSize
            let halfRealWidthDifference = realWidthDifference / 2
            tlr = tlr - halfRealWidthDifference
            brr = brr + halfRealWidthDifference
        }
        let calculatedHeight = imaginaryHeight / stepSize
        if calculatedHeight < rectHeight {
            let heightDifference = rectHeight - calculatedHeight
            let imaginaryHeightDifference = heightDifference * stepSize
            let halfImaginaryHeightDifference = imaginaryHeightDifference / 2
            tli = tli + halfImaginaryHeightDifference
            bri = bri - halfImaginaryHeightDifference
        }
        
        return ComplexRect<T>(Complex<T>(tlr, tli), Complex<T>(brr, bri))
    }
}