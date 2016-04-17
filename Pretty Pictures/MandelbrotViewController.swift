import UIKit



class MandelbrotViewController: UIViewController
{
    var mandelbrotRect = ComplexRect(Complex(-2.1, 1.5), Complex(1.0, -1.5))
    private var visibleComplexRect: ComplexRect {
        get {
            let topLeft = self.mandelbrotRect.topLeft
            let bottomRight = self.mandelbrotRect.bottomRight

            let viewWidth = Double(CGRectGetWidth(self.view.bounds))
            let viewHeight = Double(CGRectGetHeight(self.view.bounds))

            var tlr = topLeft.real
            var tli = topLeft.imaginary
            var brr = bottomRight.real
            var bri = bottomRight.imaginary

            var aspectRatio: Double
            if viewWidth > viewHeight {
                aspectRatio = viewWidth / viewHeight
                tlr = topLeft.real * aspectRatio
                brr = bottomRight.real * aspectRatio
            } else {
                aspectRatio = viewHeight / viewWidth
                tli = topLeft.imaginary * aspectRatio
                bri = bottomRight.imaginary * aspectRatio
            }

            return ComplexRect(Complex(tlr, tli), Complex(brr, bri))
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let scaleFactor = UIScreen.mainScreen().scale
        let screenWidth = CGRectGetWidth(self.view.bounds) * scaleFactor
        let screenHeight = CGRectGetHeight(self.view.bounds) * scaleFactor
        let realWidth = abs(self.visibleComplexRect.bottomRight.real - self.visibleComplexRect.topLeft.real)
        let realStepSize = realWidth / Double(screenWidth)
        let imaginaryHeight = abs(self.visibleComplexRect.bottomRight.imaginary - self.visibleComplexRect.topLeft.imaginary)
        let imaginaryStepSize = imaginaryHeight / Double(screenHeight)
//        let m = MandelbrotView(frame: self.view.bounds)
//        self.view.addSubview(m)
//
//        let viewsDictionary = ["m": m]
//        let constraints = NSLayoutConstraint.constraintsWithVisualFormat("|[m]|", options: [.AlignAllTop, .AlignAllBottom], metrics: nil, views: viewsDictionary)
//        self.view.addConstraints(constraints)

        let mc = MandelbrotCalculator()
        let states = mc.pointsForComplexRect(self.visibleComplexRect, realStepSize: realStepSize, imaginaryStepSize: imaginaryStepSize, maximumIterations: 1024)
        var tile = ContinuousColorTile(states: states, maximumIterations: 1024, width:Int(screenWidth), height: Int(screenHeight))
        var pixels = [UInt8]()
        let values = tile.intensities
        if let intensities = tile.colorLookup {
            for y in 0 ..< Int(screenHeight) {
                for x in 0 ..< Int(screenWidth) {
                    let index = y * Int(screenWidth) + x
                    let intensity = intensities[index]
                    var red: CGFloat = 0.0
                    var green: CGFloat = 0.0
                    var blue: CGFloat = 0.0
                    var alpha: CGFloat = 0.0

                    intensity.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                    let gray = red * 255 * 0.2126 + green * 255 * 0.7152 + blue * 255 * 0.0722

                    pixels.append(UInt8(gray))
                }
            }
            let image = self.imageFromPixelValues(pixels, width: Int(screenWidth), height: Int(screenHeight))
            let im = UIImage(CGImage: image!, scale: scaleFactor, orientation: .Up)
            print("\(im)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func imageFromPixelValues(pixelValues: [UInt8]?, width: Int, height: Int) -> CGImage?
    {
        var imageRef: CGImage?
        if let pixelValues = pixelValues {
            let bitsPerComponent = 8
            let bytesPerPixel = 1
            let bitsPerPixel = bytesPerPixel * bitsPerComponent
            let bytesPerRow = bytesPerPixel * width
            let totalBytes = height * bytesPerRow
            let providerRef = CGDataProviderCreateWithData(nil, pixelValues, totalBytes, nil)

            let colorSpaceRef = CGColorSpaceCreateDeviceGray()
            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.None.rawValue)
                .union(.ByteOrderDefault)
            imageRef = CGImageCreate(width,
                                     height,
                                     bitsPerComponent,
                                     bitsPerPixel,
                                     bytesPerRow,
                                     colorSpaceRef,
                                     bitmapInfo,
                                     providerRef,
                                     nil,
                                     false,
                                     CGColorRenderingIntent.RenderingIntentDefault)
        }
        
        return imageRef
    }

}

