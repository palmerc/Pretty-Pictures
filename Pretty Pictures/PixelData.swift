import Foundation



public struct PixelData: CustomStringConvertible, CustomDebugStringConvertible
{
    var red: UInt8
    var green: UInt8
    var blue: UInt8
    var alpha: UInt8
    public var description: String
    {
        get {
            return String(format: "%s(r: %d, g: %d, b: %d, a: %d)", String(self), red, green, blue, alpha)
        }
    }
    public var debugDescription: String
    {
        get {
            return String(format: "%s(r: %d, g: %d, b: %d, a: %d)", String(self), red, green, blue, alpha)
        }
    }

    init(red: Double, green: Double, blue: Double, alpha: Double? = 1.0) {
        let clampRange = 0...1
        let scaledRed = UInt8(round(red.clamp(clampRange) * 255))
        let scaledGreen = UInt8(round(green.clamp(clampRange) * 255))
        let scaledBlue = UInt8(round(blue.clamp(clampRange) * 255))
        var scaledAlpha: UInt8 = 255
        if let alpha = alpha {
            scaledAlpha = UInt8(round(alpha.clamp(clampRange) * 255))
        }

        self.init(red: scaledRed, green: scaledGreen, blue: scaledBlue, alpha: scaledAlpha)
    }
    init(red: Float, green: Float, blue: Float, alpha: Float? = 1.0) {
        let clampRange = 0...1
        let scaledRed = UInt8(round(red.clamp(clampRange) * 255))
        let scaledGreen = UInt8(round(green.clamp(clampRange) * 255))
        let scaledBlue = UInt8(round(blue.clamp(clampRange) * 255))
        var scaledAlpha: UInt8 = 255
        if let alpha = alpha {
            scaledAlpha = UInt8(round(alpha.clamp(clampRange) * 255))
        }

        self.init(red: scaledRed, green: scaledGreen, blue: scaledBlue, alpha: scaledAlpha)
    }
    init(red: Int, green: Int, blue: Int, alpha: Int? = 255) {
        let clampRange = 0...255
        let scaledRed = UInt8(red.clamp(clampRange))
        let scaledGreen = UInt8(green.clamp(clampRange))
        let scaledBlue = UInt8(blue.clamp(clampRange))
        var scaledAlpha: UInt8 = 255
        if let alpha = alpha {
            scaledAlpha = UInt8(alpha.clamp(clampRange))
        }

        self.init(red: scaledRed, green: scaledGreen, blue: scaledBlue, alpha: scaledAlpha)
    }
    init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8? = 255) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha!
    }
    init()
    {
        self.init(red: 0, green: 0, blue: 0)
    }

    static func pixelDataFromHSB(hue hue: Double, saturation: Double, brightness: Double, alpha: Double? = 1.0) -> PixelData
    {
        let percentageClamp = 0...1
        let hueClamped = hue.clamp(percentageClamp)

        let degreesInACircle = 360.0
        let hueAngle = hueClamped * degreesInACircle

        return PixelData.pixelDataFromHSB(hueAngle: hueAngle, saturation: saturation, brightness: brightness, alpha: alpha)
    }

    static func pixelDataFromHSB(hueAngle hueAngle: Double, saturation: Double, brightness: Double, alpha: Double? = 1.0) -> PixelData
    {
        let sizeOfHSVSector = 60.0

        let angleClamp = 0...360
        let percentageClamp = 0...1
        let hueClamped = hueAngle.clamp(angleClamp)
        let saturationClamped = saturation.clamp(percentageClamp)
        let brightnessClamped = brightness.clamp(percentageClamp)

        let C = brightnessClamped * saturationClamped
        let huePrime = hueClamped / sizeOfHSVSector
        let X = C * (1 - abs(huePrime % 2 - 1))

        var red: Double
        var green: Double
        var blue: Double
        switch (floor(huePrime)) {
        case 0:
            red = C
            green = X
            blue = 0.0
            break;
        case 1:
            red = X
            green = C
            blue = 0.0
            break;
        case 2:
            red = 0.0
            green = C
            blue = X
            break;
        case 3:
            red = 0.0
            green = X
            blue = C
            break;
        case 4:
            red = X
            green = 0.0
            blue = C
            break;
        case 5:
            red = C
            green = 0.0
            blue = X
            break;
        default:
            red = 0.0
            green = 0.0
            blue = 0.0
            break;
        }

        var alphaClamped = 1.0
        if let alpha = alpha {
            alphaClamped = alpha.clamp(percentageClamp)
        }

        let m = brightnessClamped - C

        let rgbaClamp = 0...255
        let r = UInt8(ceil((red + m) * 255.0).clamp(rgbaClamp))
        let g = UInt8(ceil((green + m) * 255.0).clamp(rgbaClamp))
        let b = UInt8(ceil((blue + m) * 255.0).clamp(rgbaClamp))
        let a = UInt8(ceil(alphaClamped * 255.0).clamp(rgbaClamp))

        return PixelData(red: r, green: g, blue: b, alpha: a)
    }
}
