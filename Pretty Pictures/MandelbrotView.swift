import UIKit



public class MandelbrotView: UIView
{
    private let blockiness = 0.1 // pick a value from 0.25 to 5.0
    private let colorCount = 64
    private var colorSet = Array<UIColor>()

    public var mandelbrotRect = ComplexRect<Double>(Complex<Double>(-2.1, 1.5), Complex<Double>(1.0, -1.5))

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

    private func computeMandelbrotPoint(C: Complex<Double>) -> UIColor
    {
        // Calculate whether the point is inside or outside the Mandelbrot set
        // Zn+1 = (Zn)^2 + c -- start with Z0 = 0

        var z = Complex<Double>(0, 0)
        for iteration in 1...colorCount {
            z = z*z + C
            if abs(z) > 2 {
                return colorSet[iteration] // bail as soon as the complex number is too big (you're outside the set & it'll go to infinity)
            }
        }
        // Yay, you're inside the set!
        return UIColor.blackColor()
    }

    private func complexCoordinatesWithViewCoordinates(x x: Double, y: Double, rect: CGRect) -> Complex<Double>
    {
        let topLeft = self.visibleComplexRect.topLeft
        let bottomRight = self.visibleComplexRect.bottomRight

        let viewWidth = Double(rect.size.width)
        let viewHeight = Double(rect.size.height)

        let difference = bottomRight - topLeft
        let real = topLeft.re + (x / viewWidth * difference.re)
        let imaginary = topLeft.im + (y / viewHeight * difference.im)

        return Complex(real, imaginary)
    }

    private func complexCoordinatesToViewCoordinates(c: Complex<Double>, rect: CGRect) -> CGPoint
    {
        let topLeft = self.visibleComplexRect.topLeft
        let bottomRight = self.visibleComplexRect.bottomRight
        let x = (c.re - topLeft.re) / (bottomRight.re - topLeft.re) * Double(rect.size.width)
        let y = (c.im - topLeft.im) / (bottomRight.im - topLeft.im) * Double(rect.size.height)

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