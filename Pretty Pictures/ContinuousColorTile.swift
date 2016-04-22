import UIKit
import CoreGraphics



public class ContinuousColorTile : Tile
{
    private var _states: [[FractalState]]
    private var _colors: [[PixelData]]?
    public var colors: [[PixelData]]? {
        get {
            if _colors == nil {
                computeColors()
            }
            return _colors
        }
    }

    init(states: [[FractalState]])
    {
        self._states = states
    }

    private func computeColors()
    {
        self._colors = _states.map({
            (stateVector: [FractalState]) -> [PixelData] in

            return stateVector.map({ (state: FractalState) -> PixelData in
                var color: PixelData

                switch (state.type) {
                case .Mandelbrot:
                    color = self.colorForMandelbrotFractalState(state)
                    break
                case .Julia:
                    color = self.colorForJuliaFractalState(state)
                    break
                case .BurningShip:
                    color = self.colorForMandelbrotFractalState(state)
                    break
                }

                return color
            })
        })
    }

    private func colorForMandelbrotFractalState(state: FractalState) -> PixelData
    {
        var color: PixelData = PixelData(red: 0, green: 0, blue: 0)
        if state.iterations > 0 {
            let z = state.z
            let degree = Double(state.degree) * 2
            let length = sqrt(pow(z.re, 2) + pow(z.im, 2))
            let normalized = log(log(length)) / log(degree)
            let hueAngle = Double(state.iterations) + 1.0 - normalized
            let hueAdjustment = 20.0 * hueAngle + 0.95;
            var angle = hueAdjustment % 360.0
            if angle < 0.0 {
                angle = angle + 360.0
            }

            color = PixelData.pixelDataFromHSB(hueAngle: angle, saturation: 0.91, brightness: 0.99)
        }

        return color
    }

    private func colorForJuliaFractalState(state: FractalState) -> PixelData
    {
        var color: PixelData = PixelData(red: 0, green: 0, blue: 0)
        if state.iterations > 0 {
            let z = state.z
            let degree = Double(state.degree) * 2
            let length = sqrt(pow(z.re, 2) + pow(z.im, 2))
            let normalized = log(log(length)) / log(degree * 2)
            let hueAngle = Double(state.iterations) + 1.0 - normalized
            let hueAdjustment = 10.0 * hueAngle + 0.95;
            var angle = hueAdjustment % 360.0
            if angle < 0.0 {
                angle = angle + 360.0
            }

            color = PixelData.pixelDataFromHSB(hueAngle: angle, saturation: 0.91, brightness: 0.99)
        }

        return color
    }
}

extension ContinuousColorTile {
    public var CGImage: CGImageRef? {
        get {
            var imageRef: CGImageRef?

            var width = 0
            var height = 0
            if let row = self._states.first {
                height = self._states.count
                width = row.count
            }

            if let colors = self.colors, pixelValues: [PixelData] = Array<PixelData>(colors.flatten()) {
                let bitsPerComponent = 8
                let bytesPerPixel = 4
                let bitsPerPixel = bytesPerPixel * bitsPerComponent
                let bytesPerRow = bytesPerPixel * width
                let totalBytes = height * bytesPerRow
                let providerRef = CGDataProviderCreateWithData(nil, pixelValues, totalBytes, nil)

                let colorSpaceRef = CGColorSpaceCreateDeviceRGB()
                let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.NoneSkipLast.rawValue)
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
    private func pixelDataColorSet(numberOfColors count: Int) -> [PixelData]
    {
        var colorSet = [PixelData](count: count, repeatedValue: PixelData())
        for index in 0 ..< count {
            let hue = abs(sin(Double(index) / 30.0))
            let saturation = 1.0
            let brightness = Double(index) / 100.0 + 0.8

            colorSet[index] = PixelData.pixelDataFromHSB(hue: hue, saturation: saturation, brightness: brightness)
        }

        return colorSet
    }
}