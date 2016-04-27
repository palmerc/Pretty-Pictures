import UIKit
import CoreGraphics



public class IntensityTile : Tile
{
    private var _states: [[FractalState]]
    private var _intensities: [[UInt8]]?
    public var intensities: [[UInt8]]? {
        get {
            if _intensities == nil {
                computeIntensities()
            }
            return _intensities
        }
    }

    init(states: [[FractalState]])
    {
        self._states = states
    }

    private func computeIntensities()
    {
        let epsilon = 0.001
        var minimumValue = Double(CGFloat.max)
        let decibels = _states.map({
            (stateVector: [FractalState]) -> [Double] in
            return stateVector.map({ (state: FractalState) -> Double in
                let decibel = 20.0 * log10(Double(state.iterations) + epsilon)
                minimumValue = min(minimumValue, decibel)
                return decibel
            })
        })
        var maximumValue: Double = 0
        let shiftedValues = decibels.map({
            (decibelVector: [Double]) -> [Double] in
            return decibelVector.map({
                (decibel: Double) -> Double in
                let shiftedValue = decibel - minimumValue
                maximumValue = max(shiftedValue, maximumValue)
                return shiftedValue
            })
        })
        self._intensities = shiftedValues.map({
            (shiftedValuesVector: [Double]) -> [UInt8] in
            return shiftedValuesVector.map({
                (shiftedValue: Double) -> UInt8 in
                let percentage = shiftedValue / maximumValue
                return UInt8(round(percentage * 255.0))
            })
        })
    }
}

extension IntensityTile {
    public var CGImage: CGImageRef? {
        get {
            var imageRef: CGImageRef?

            var width = 0
            var height = 0
            if let row = self._states.first {
                height = self._states.count
                width = row.count
            }

            if let intensities = self.intensities, pixelValues: [UInt8] = Array<UInt8>(intensities.flatten()) {
                let bitsPerComponent = 8
                let bytesPerPixel = 1
                let bitsPerPixel = bytesPerPixel * bitsPerComponent
                let bytesPerRow = bytesPerPixel * width
                let totalBytes = height * bytesPerRow
                
                let pixelData = NSData(bytes: pixelValues, length: totalBytes)
                let providerRef = CGDataProviderCreateWithCFData(pixelData)

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
}