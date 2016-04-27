import Foundation



extension Double
{
    func clamp(range: Range<Int>) -> Double
    {
        var result = self
        if let minimum = range.first {
            if result < Double(minimum) {
                result = Double(minimum)
            }
        }
        if let maximum = range.last {
            if result > Double(maximum) {
                result = Double(maximum)
            }
        }

        return result
    }
}

extension Float
{
    func clamp(range: Range<Int>) -> Float
    {
        var result = self
        if let minimum = range.minElement() {
            if result < Float(minimum) {
                result = Float(minimum)
            }
        }
        if let maximum = range.maxElement() {
            if result > Float(maximum) {
                result = Float(maximum)
            }
        }

        return result
    }
}

extension Int
{
    func clamp(range: Range<Int>) -> Int
    {
        var result = self
        if let minimum = range.minElement() {
            if result < minimum {
                result = minimum
            }
        }
        if let maximum = range.maxElement() {
            if result > maximum {
                result = maximum
            }
        }

        return result
    }
}