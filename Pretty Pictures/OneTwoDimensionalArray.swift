import Foundation



public struct OneTwoDimensionalArray<T>

{
    private var _linearArray: [T]?
    private var _rows: Int = 0
    private var _columns: Int = 0

    public var linearArray: [T]?
    {
        get {
            return _linearArray
        }
    }
    public var rows: Int {
        get {
            return _rows
        }
    }
    public var columns: Int {
        get {
            return _columns
        }
    }
    public var count: Int {
        get {
            guard let linearArray = _linearArray else {
                return 0
            }
            return linearArray.count
        }
    }

    init(rows: Int, columns: Int, repeatedValue: T)
    {
        _rows = rows
        _columns = columns
        _linearArray = [T](count: rows * columns, repeatedValue: repeatedValue)
    }

    init(twoDimensionalArray: [[T]])
    {
        if let columns = twoDimensionalArray.first {
            _rows = twoDimensionalArray.count
            _columns = columns.count
            _linearArray = Array<T>(twoDimensionalArray.flatten())
        }
    }

    init(rows: Int, columns: Int, oneDimensionalArray: [T])
    {
        _rows = rows
        _columns = columns
        _linearArray = oneDimensionalArray
    }

    public subscript(index: Int) -> T?
    {
        get {
            return self.elementAt(index: index)
        }
        set {
            self.setElement(newValue, index: index)
        }
    }

    public subscript(row: Int, column: Int) -> T?
    {
        get {
            return self.elementAt(row: row, column: column)
        }
        set {
            self.setElement(newValue, row: row, column: column)
        }
    }

    public func elementAt(index index: Int) -> T?
    {
        guard let linearArray = _linearArray else {
            print("Array is uninitialized.")
            return nil
        }
        guard indexIsValid(index) else {
            print("Index out of range")
            return nil
        }

        return linearArray[index]
    }

    public func elementAt(row row: Int, column: Int) -> T?
    {
        let index = (row * _columns) + column
        return elementAt(index: index)
    }

    public mutating func setElement(element: T?, index: Int)
    {
        guard var linearArray = _linearArray else {
            print("Array is uninitialized.")
            return
        }

        guard let object = element else {
            print("Object is nil")
            return
        }

        guard indexIsValid(index) else {
            print("Index out of range")
            return
        }

        linearArray[index] = object
    }

    public mutating func setElement(element: T?, row: Int, column: Int)
    {
        let index = (row * _columns) + column
        self.setElement(element, index: index)
    }

    func indexIsValid(index: Int) -> Bool
    {
        return index >= 0 && index < _rows * _columns
    }
}
