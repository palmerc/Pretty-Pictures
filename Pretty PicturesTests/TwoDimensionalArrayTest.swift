import XCTest
@testable import Pretty_Pictures



class TwoDimensionalArrayTest: XCTestCase {
    var _intensityValues: [UInt8]?
    var _width = 0
    var _height = 0

    override func setUp()
    {
        super.setUp()

        let bundle = NSBundle(forClass: self.dynamicType)
        let imageURL = bundle.URLForResource("zebra_5", withExtension: "png")
        guard let fileURL = imageURL else {
            XCTFail("Testing image was not initialized.")
            return
        }

        guard let filePath = fileURL.path else {
            XCTFail("Testing image path is nil.")
            return
        }

        var testImage: UIImage?
        if NSFileManager().fileExistsAtPath(filePath) {
            testImage = UIImage(contentsOfFile: filePath)
        }

        guard let image = testImage else {
            XCTFail("Testing image was not initialized.")
            return
        }

        let (intensityValues, width, height) = pixelValuesFromImage(image.CGImage)
        _intensityValues = intensityValues
        _width = width
        _height = height
    }
    
    override func tearDown()
    {
        super.tearDown()
    }

    func testTwoDimensionalArraySimpleMap()
    {
        let oneTwoArray = OneTwoDimensionalArray(rows: _height, columns: _width, oneDimensionalArray: _intensityValues!)

        if let linearArray = oneTwoArray.linearArray {
            let copy = linearArray.map({ (value: UInt8) -> UInt8 in
                return value
            })

            XCTAssertEqual(linearArray, copy)
        } else {
            XCTFail()
        }
    }

    func testTwoDimensionalArrayTwoDAssignment()
    {
        let rows = 100, columns = 100
        var array = [[Int]](count: rows, repeatedValue: [Int](count: columns, repeatedValue: 0))
        for rowIndex in 0 ..< rows {
            for columnIndex in 0 ..< columns {
                let value = rowIndex * columns + columnIndex
                array[rowIndex][columnIndex] = value
            }
        }
        let oneTwoArray = OneTwoDimensionalArray(twoDimensionalArray: array)
        let filteredArray = oneTwoArray.linearArray?.enumerate().filter({ (index: Int, element: Int) -> Bool in
            return index != element
        })

        XCTAssertEqual(filteredArray!.count, 0)
    }

    func pixelValuesFromImage(imageRef: CGImage?) -> (pixelValues: [UInt8]?, width: Int, height: Int)
    {
        var width = 0
        var height = 0
        var pixelValues: [UInt8]?
        if let imageRef = imageRef {
            width = CGImageGetWidth(imageRef)
            height = CGImageGetHeight(imageRef)
            let bitsPerComponent = CGImageGetBitsPerComponent(imageRef)
            let bytesPerRow = CGImageGetBytesPerRow(imageRef)
            let totalBytes = height * bytesPerRow

            let colorSpace = CGColorSpaceCreateDeviceGray()
            var intensities = [UInt8](count: totalBytes, repeatedValue: 0)

            let contextRef = CGBitmapContextCreate(&intensities, width, height, bitsPerComponent, bytesPerRow, colorSpace, 0)
            CGContextDrawImage(contextRef, CGRectMake(0.0, 0.0, CGFloat(width), CGFloat(height)), imageRef)

            pixelValues = intensities
        }
        
        return (pixelValues, width, height)
    }
}
