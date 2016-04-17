import UIKit



public class MandelbrotView: UIView
{
    private let blockiness = 0.1 // pick a value from 0.25 to 5.0
    private let colorCount = 64
    private var colorSet = Array<UIColor>()

    public var mandelbrotRect = ComplexRect(Complex(-2.1, 1.5), Complex(1.0, -1.5))
    private var visibleComplexRect: ComplexRect {
        get {
            let topLeft = self.mandelbrotRect.topLeft
            let bottomRight = self.mandelbrotRect.bottomRight

            let viewWidth = CGRectGetWidth(self.bounds)
            let viewHeight = CGRectGetHeight(self.bounds)

            var tlr = topLeft.real
            var tli = topLeft.imaginary
            var brr = bottomRight.real
            var bri = bottomRight.imaginary

            if viewWidth > viewHeight {
                let scalingFactor = Double(viewWidth / viewHeight)
                tlr = topLeft.real * scalingFactor
                brr = bottomRight.real * scalingFactor
            } else {
                let scalingFactor = Double(viewHeight / viewWidth)
                tli = topLeft.imaginary * scalingFactor
                bri = bottomRight.imaginary * scalingFactor
            }

            return ComplexRect(Complex(tlr, tli), Complex(brr, bri))
        }
    }

    public override func drawRect(rect : CGRect)
    {
        UIBezierPath(rect: rect).fill()
        let elapsedTime = self.executionTime { 
            self.drawMandelbrot(rect)
        }

        print("Elapsed time: \(elapsedTime) seconds")
    }

    private func initializeColors()
    {
        if colorSet.count < 2 {
            colorSet = Array()
            for index in 0...self.colorCount {
                let indexD = CGFloat(index)
                let color = UIColor(hue: abs(sin(indexD/30.0)),
                                    saturation: 1.0,
                                    brightness: indexD/100.0 + 0.8,
                                    alpha: 1.0)
                colorSet.append(color)
            }
        }
    }

    private func computeMandelbrotPoint(C: Complex) -> UIColor
    {
        // Calculate whether the point is inside or outside the Mandelbrot set
        // Zn+1 = (Zn)^2 + c -- start with Z0 = 0

        var z = Complex(0, 0)
        for iteration in 1...colorCount {
            z = z*z + C
            if abs(z) > 2 {
                return colorSet[iteration] // bail as soon as the complex number is too big (you're outside the set & it'll go to infinity)
            }
        }
        // Yay, you're inside the set!
        return UIColor.blackColor()
    }

    private func complexCoordinatesWithViewCoordinates(x x: Double, y: Double, rect: CGRect) -> Complex
    {
        let topLeft = self.visibleComplexRect.topLeft
        let bottomRight = self.visibleComplexRect.bottomRight

        let viewWidth = Double(rect.size.width)
        let viewHeight = Double(rect.size.height)

        let difference = bottomRight - topLeft
        let real = topLeft.real + (x / viewWidth * difference.real)
        let imaginary = topLeft.imaginary + (y / viewHeight * difference.imaginary)

        return Complex(real, imaginary)
    }

    private func complexCoordinatesToViewCoordinates(c: Complex, rect: CGRect) -> CGPoint
    {
        let topLeft = self.visibleComplexRect.topLeft
        let bottomRight = self.visibleComplexRect.bottomRight
        let x = (c.real - topLeft.real) / (bottomRight.real - topLeft.real) * Double(rect.size.width)
        let y = (c.imaginary - topLeft.imaginary) / (bottomRight.imaginary - topLeft.imaginary) * Double(rect.size.height)

        return CGPoint(x: x,y: y)
    }

    func drawMandelbrot(rect : CGRect)
    {
        let width = Double(rect.size.width)
        let height = Double(rect.size.height)

        let elapsedTime = executionTime { 
            self.initializeColors()
            for x in 0.stride(through: width, by: self.blockiness) {
                for y in 0.stride(through: height, by: self.blockiness) {
                    let cc = self.complexCoordinatesWithViewCoordinates(x: x, y: y, rect: rect)
                    self.computeMandelbrotPoint(cc).set()
                    UIBezierPath(rect: CGRect(x: x, y: y, width: self.blockiness, height: self.blockiness)).fill()
                }
            }
        }

        print("Calculation time: \(elapsedTime)")
    }

    private func executionTime(block: ()->()) -> CFAbsoluteTime
    {
        let startTime = CACurrentMediaTime()
        block()
        let endTime = CACurrentMediaTime()
        return endTime - startTime
    }
}