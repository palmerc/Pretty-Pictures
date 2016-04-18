import UIKit



class ShipViewController: UIViewController
{
    var startRect = ComplexRect<Double>(Complex<Double>(1.936, 0.008998), Complex<Double>(1.945998, -0.001))
    var defaultCoordinate = (u: 1.941, v: -0.004)

    override func viewDidLoad() {
        super.viewDidLoad()

        let scaleFactor = UIScreen.mainScreen().scale
        let screenWidth = CGRectGetWidth(self.view.bounds) * scaleFactor
        let screenHeight = CGRectGetHeight(self.view.bounds) * scaleFactor
        let targetRect = CGRectMake(0, 0, screenWidth, screenHeight)
        let visibleComplexRect = self.startRect.fitCGRect(toCGRect: targetRect)

        let stepSize = self.startRect.width / Double(screenWidth)

//        let sc = ShipCalculator()
//        let states = sc.pointsForComplexRect(visibleComplexRect, stepSize: stepSize, maximumIterations: 255)
//        var tile = ContinuousColorTile(states: states, maximumIterations: 255, width:Int(screenWidth), height: Int(screenHeight))
//        var pixels = [UInt8]()
//        if let intensities = tile.colorLookup {
//            for y in 0 ..< Int(screenHeight) {
//                for x in 0 ..< Int(screenWidth) {
//                    let index = y * Int(screenWidth) + x
//                    let intensity = intensities[index]
//                    var red: CGFloat = 0.0
//                    var green: CGFloat = 0.0
//                    var blue: CGFloat = 0.0
//                    var alpha: CGFloat = 0.0
//
//                    intensity.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
//                    let gray = red * 255 * 0.2126 + green * 255 * 0.7152 + blue * 255 * 0.0722
//
//                    pixels.append(UInt8(gray))
//                }
//            }
//            let image = self.imageFromPixelValues(pixels, width: Int(screenWidth), height: Int(screenHeight))
//            let im = UIImage(CGImage: image!, scale: scaleFactor, orientation: .Up)
//            print("\(im)")
//        }
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