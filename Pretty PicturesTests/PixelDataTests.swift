import XCTest
@testable import Pretty_Pictures



class PixelDataTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testDecimal() {
        let pixelData1 = PixelData(red: 0.5, green: 0.5, blue: 0.5)
        XCTAssertEqual(pixelData1.red, 128)
        XCTAssertEqual(pixelData1.green, 128)
        XCTAssertEqual(pixelData1.blue, 128)
        XCTAssertEqual(pixelData1.alpha, 255)

        let overflow = PixelData(red: 1.1, green: 1.1, blue: 1.1)
        XCTAssertEqual(overflow.red, 255)
        XCTAssertEqual(overflow.green, 255)
        XCTAssertEqual(overflow.blue, 255)
        XCTAssertEqual(overflow.alpha, 255)

        let underflow = PixelData(red: -1.1, green: -1.1, blue: -1.1)
        XCTAssertEqual(underflow.red, 0)
        XCTAssertEqual(underflow.green, 0)
        XCTAssertEqual(underflow.blue, 0)
        XCTAssertEqual(underflow.alpha, 255)
    }

    func testHSVToPixelData() {
        let black = PixelData.pixelDataFromHSB(hue: 0.0, saturation: 0.0, brightness: 0.0)
        XCTAssertEqual(black.red, 0)
        XCTAssertEqual(black.green, 0)
        XCTAssertEqual(black.blue, 0)
        XCTAssertEqual(black.alpha, 255)

        let white = PixelData.pixelDataFromHSB(hue: 0.0, saturation: 0.0, brightness: 1.0)
        XCTAssertEqual(white.red, 255)
        XCTAssertEqual(white.green, 255)
        XCTAssertEqual(white.blue, 255)
        XCTAssertEqual(white.alpha, 255)

        let red = PixelData.pixelDataFromHSB(hue: 0.0, saturation: 1.0, brightness: 1.0)
        XCTAssertEqual(red.red, 255)
        XCTAssertEqual(red.green, 0)
        XCTAssertEqual(red.blue, 0)
        XCTAssertEqual(red.alpha, 255)

        let lime = PixelData.pixelDataFromHSB(hue: 120.0/360.0, saturation: 1.0, brightness: 1.0)
        XCTAssertEqual(lime.red, 0)
        XCTAssertEqual(lime.green, 255)
        XCTAssertEqual(lime.blue, 0)
        XCTAssertEqual(lime.alpha, 255)

        let blue = PixelData.pixelDataFromHSB(hue: 240.0/360.0, saturation: 1.0, brightness: 1.0)
        XCTAssertEqual(blue.red, 0)
        XCTAssertEqual(blue.green, 0)
        XCTAssertEqual(blue.blue, 255)
        XCTAssertEqual(blue.alpha, 255)

        let yellow = PixelData.pixelDataFromHSB(hue: 60.0/360.0, saturation: 1.0, brightness: 1.0)
        XCTAssertEqual(yellow.red, 255)
        XCTAssertEqual(yellow.green, 255)
        XCTAssertEqual(yellow.blue, 0)
        XCTAssertEqual(yellow.alpha, 255)

        let cyan = PixelData.pixelDataFromHSB(hue: 180.0/360.0, saturation: 1.0, brightness: 1.0)
        XCTAssertEqual(cyan.red, 0)
        XCTAssertEqual(cyan.green, 255)
        XCTAssertEqual(cyan.blue, 255)
        XCTAssertEqual(cyan.alpha, 255)

        let magenta = PixelData.pixelDataFromHSB(hue: 300.0/360.0, saturation: 1.0, brightness: 1.0)
        XCTAssertEqual(magenta.red, 255)
        XCTAssertEqual(magenta.green, 0)
        XCTAssertEqual(magenta.blue, 255)
        XCTAssertEqual(magenta.alpha, 255)

        let silver = PixelData.pixelDataFromHSB(hue: 0.0/360.0, saturation: 0.0, brightness: 0.75)
        XCTAssertEqual(silver.red, 192)
        XCTAssertEqual(silver.green, 192)
        XCTAssertEqual(silver.blue, 192)
        XCTAssertEqual(silver.alpha, 255)

        let gray = PixelData.pixelDataFromHSB(hue: 0.0/360.0, saturation: 0.0, brightness: 0.5)
        XCTAssertEqual(gray.red, 128)
        XCTAssertEqual(gray.green, 128)
        XCTAssertEqual(gray.blue, 128)
        XCTAssertEqual(gray.alpha, 255)

        let maroon = PixelData.pixelDataFromHSB(hue: 0.0/360.0, saturation: 1.0, brightness: 0.5)
        XCTAssertEqual(maroon.red, 128)
        XCTAssertEqual(maroon.green, 0)
        XCTAssertEqual(maroon.blue, 0)
        XCTAssertEqual(maroon.alpha, 255)

        let olive = PixelData.pixelDataFromHSB(hue: 60.0/360.0, saturation: 1.0, brightness: 0.5)
        XCTAssertEqual(olive.red, 128)
        XCTAssertEqual(olive.green, 128)
        XCTAssertEqual(olive.blue, 0)
        XCTAssertEqual(olive.alpha, 255)

        let green = PixelData.pixelDataFromHSB(hue: 120.0/360.0, saturation: 1.0, brightness: 0.5)
        XCTAssertEqual(green.red, 0)
        XCTAssertEqual(green.green, 128)
        XCTAssertEqual(green.blue, 0)
        XCTAssertEqual(green.alpha, 255)

        let purple = PixelData.pixelDataFromHSB(hue: 300.0/360.0, saturation: 1.0, brightness: 0.5)
        XCTAssertEqual(purple.red, 128)
        XCTAssertEqual(purple.green, 0)
        XCTAssertEqual(purple.blue, 128)
        XCTAssertEqual(purple.alpha, 255)

        let teal = PixelData.pixelDataFromHSB(hue: 180.0/360.0, saturation: 1.0, brightness: 0.5)
        XCTAssertEqual(teal.red, 0)
        XCTAssertEqual(teal.green, 128)
        XCTAssertEqual(teal.blue, 128)
        XCTAssertEqual(teal.alpha, 255)

        let navy = PixelData.pixelDataFromHSB(hue: 240.0/360.0, saturation: 1.0, brightness: 0.5)
        XCTAssertEqual(navy.red, 0)
        XCTAssertEqual(navy.green, 0)
        XCTAssertEqual(navy.blue, 128)
        XCTAssertEqual(navy.alpha, 255)

        let prettyOrange = PixelData.pixelDataFromHSB(hue: 40.0/360.0, saturation: 0.91, brightness: 0.99)
        XCTAssertEqual(prettyOrange.red, 253)
        XCTAssertEqual(prettyOrange.green, 176)
        XCTAssertEqual(prettyOrange.blue, 23)
        XCTAssertEqual(prettyOrange.alpha, 255)
    }
}
