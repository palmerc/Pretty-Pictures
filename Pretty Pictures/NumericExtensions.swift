import Foundation



extension Double
{
    func clamp(range: Range<Int>) -> Double
    {
        var result = self
        if let minimum = range.minElement() {
            if self < Double(minimum) {
                result = Double(minimum)
            }
        }
        if let maximum = range.maxElement() {
            if self > Double(maximum) {
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
            if self < Float(minimum) {
                result = Float(minimum)
            }
        }
        if let maximum = range.maxElement() {
            if self > Float(maximum) {
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
            if self < minimum {
                result = minimum
            }
        }
        if let maximum = range.maxElement() {
            if self > maximum {
                result = maximum
            }
        }

        return result
    }
}